{
  description = "Example flake using cardano.nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cardano-nix.url = "github:mlabs-haskell/cardano.nix/main";
  };
  outputs =
    inputs@{ self, ... }: let
      pkgs = inputs.nixpkgs.legacyPackage.x86_64-linux;
    in {
      nixosConfigurations = {
        vm = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            inputs.cardano-nix.nixosModules.default
            ./configuration.nix
            ./vm.nix
            {_module.args.inputs = inputs;}
          ];
        };
        server = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            inputs.cardano-nix.nixosModules.default
            ./configuration.nix
            # add server configuraition here
          ];
        };
      };
      packages.x86_64-linux = {
        test = self.nixosConfigurations.vm.config.system.build.tarball;
        vm = (pkgs.writeShellScriptBin "vm" "${self.nixosConfigurations.vm.config.system.build.vm}/bin/run-nixos-vm").overrideAttrs {
          pname = "test";
        };
      };
    };
}
