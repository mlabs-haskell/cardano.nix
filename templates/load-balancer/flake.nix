{
  description = "Example flake using cardano.nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cardano-nix.url = "github:mlabs-haskell/cardano.nix/main";
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs @ {self, ...}: let
    nixosSystem = modules:
      inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          modules
          ++ [
            inputs.cardano-nix.nixosModules.default
            inputs.microvm.nixosModules.microvm
            ./vm.nix
            {microvm.hypervisor = "qemu";}
          ];
      };
  in {
    nixosConfigurations = {
      load-balancer = nixosSystem [./load-balancer.nix];
      node1 = nixosSystem [./preview.nix {networking.hostName = "node1";}];
      node2 = nixosSystem [./preview.nix {networking.hostName = "node2";}];
      node3 = nixosSystem [./preview.nix {networking.hostName = "node3";}];
    };
    devShells.x86_64-linux.default = inputs.nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = [inputs.microvm.packages.x86_64-linux.microvm];
    };
    packages.x86_64-linux = {
      inherit (inputs.microvm.packages.x86_64-linux) microvm;
      vms = inputs.nixpkgs.legacyPackages.x86_64-linux.writeShellApplication {
        name = "vms";
        meta.description = "Run virtual machines.";
        runtimeInputs = [inputs.microvm.packages.x86_64-linux.microvm];
        text = ''
          microvm
        '';
      };
    };
    apps.x86_64-linux = {
      vms = {
        type = "app";
        program = "${self.packages.x86_64-linux.vms}/bin/vms";
      };
    };
  };
}
