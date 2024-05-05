{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    # Cardano-node
    cardano-node = {
      url = "github:intersectmbo/cardano-node?ref=8.7.3";
    };
    cardano-configurations = {
      # This version is compatible with cardano-node above and likely needs to be updated together.
      url = "github:input-output-hk/cardano-configurations/21249e0d5c68b4e8f3661b250aa8272a8785d678";
      flake = false;
    };
    cardano-db-sync = {
      url = "github:intersectmbo/cardano-db-sync/13.2.0.1"; # compatible with 8.7.3
    };

    # Utilities
    attic = {
      url = "github:zhaofengli/attic";
      # doesn't build yet with our nixpkgs
    };
    devour-flake = {
      url = "github:srid/devour-flake";
      flake = false;
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    flake-root = {
      url = "github:srid/flake-root";
    };
    hercules-ci-effects = {
      url = "github:mlabs-haskell/hercules-ci-effects/push-cache-effect";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake
    {
      inherit inputs;
    }
    {
      debug = true;
      imports = [
        ./checks
        ./ci
        ./configurations
        ./docs
        ./formatter
        ./modules
        ./shell
        ./tests
        ./packages
      ];
      flake.templates.default = {
        path = ./template;
        description = "Example flake using cardano.nix";
      };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        # Ogmios doesn't support it
        # "x86_64-darwin"
        # We don't have a builder
        # "aarch64-darwin"
      ];
    };
}
