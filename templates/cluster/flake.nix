{
  description = "Example flake using cardano.nix";
  inputs = {
    cardano-nix.url = "github:mlabs-haskell/cardano.nix/main";
    nixpkgs.follows = "cardano-nix/nixpkgs";
  };
  outputs = {
    cardano-nix,
    nixpkgs,
    ...
  }: {
    nixosConfigurations = {
      node1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [{networking.hostName = "node1";} ./preview.nix cardano-nix.nixosModules.default];
      };
      node2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [{networking.hostName = "node2";} ./preview.nix cardano-nix.nixosModules.default];
      };
      node3 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [{networking.hostName = "node3";} ./preview.nix cardano-nix.nixosModules.default];
      };
      status = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./status.nix cardano-nix.nixosModules.default];
      };
      proxy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./proxy.nix cardano-nix.nixosModules.default];
      };
    };
    packages.x86_64-linux = {
      vms =
        ((import (nixpkgs.outPath + "/nixos/lib") {}).runTest {
          name = "cluster";
          imports = [
            {
              nodes.node1 = ./preview.nix;
              nodes.node2 = ./preview.nix;
              nodes.node3 = ./preview.nix;
              nodes.status = ./status.nix;
              nodes.proxy = ./proxy.nix;
              testScript = _: ''
                start_all()
                join_all()
                while True:
                    proxy.sleep(60)
              '';
            }
          ];
          hostPkgs = nixpkgs.legacyPackages.x86_64-linux;
          defaults.imports = [
            ./vm.nix
            cardano-nix.nixosModules.default
            # Fix missing `pkgs.system` in tests.
            {nixpkgs.overlays = [(_: _: {inherit (nixpkgs.legacyPackages.x86_64-linux) system;})];}
          ];
        })
        .config
        .result
        .driver;
    };
  };
}
