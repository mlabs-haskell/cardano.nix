{
  description = "Example flake using cardano.nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cardano-nix.url = "github:mlabs-haskell/cardano.nix/main";
  };
  outputs =
    inputs@{ self, ... }:
    {
      nixosConfigurations = {
        vm = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            inputs.cardano-nix.nixosModules.default
            ./preview.nix
            ./vm.nix
          ];
        };
      };
      apps.x86_64-linux = {
        vm = {
          type = "app";
          program = "${self.nixosConfigurations.vm.config.system.build.vm}/bin/run-nixos-vm";
        };
      };
    };
}
