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
    nixosConfigurations = let
      nixosSystem = modules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = modules ++ [cardano-nix.nixosModules.default];
        };
    in {
      node1 = nixosSystem [./preview.nix {networking.hostName = "node1";}];
      node2 = nixosSystem [./preview.nix {networking.hostName = "node2";}];
      node3 = nixosSystem [./preview.nix {networking.hostName = "node3";}];
      proxy = nixosSystem [./proxy.nix];
    };
    packages.x86_64-linux = {
      vms =
        ((import (nixpkgs.outPath + "/nixos/lib") {}).runTest {
          name = "load-balancer";
          imports = [
            {
              nodes.node1 = ./preview.nix;
              nodes.node2 = ./preview.nix;
              nodes.node3 = ./preview.nix;
              nodes.proxy = ./proxy.nix;
              testScript = _: ''
                start_all()
                join_all()
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
