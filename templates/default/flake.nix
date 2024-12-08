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
            ./configuration.nix
            ./vm.nix
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
      apps.x86_64-linux = {
        vm = {
          type = "app";
          program = "${self.nixosConfigurations.vm.config.system.build.vm}/bin/run-nixos-vm";
        };
      };
    };
}
