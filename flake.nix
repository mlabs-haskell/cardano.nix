{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    # Cardano-node
    "cardano-node-9.1.0" = {
      url = "github:intersectmbo/cardano-node?ref=9.1.0";
    };
    "cardano-configurations-9.1.0" = {
      # This version is compatible with cardano-node above and likely needs to be updated together.
      url = "github:input-output-hk/cardano-configurations/7969a73e5c7ee1f3b2a40274b34191fdd8de170b";
      flake = false;
    };

    # Services
    cardano-db-sync = {
      url = "github:intersectmbo/cardano-db-sync/13.3.0.0"; # compatible with cardano-node 9.1.0
    };
    blockfrost = {
      url = "github:blockfrost/blockfrost-backend-ryo/v2.1.0"; # compatible with cardano-db-sync 13.3.0.0
    };

    oura = {
      url = "github:txpipe/oura/v1.9.0";
      inputs.crane.follows = "crane";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Utilities
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
        # cardano-node doesn't support it
        # "aarch64-linux"
        # ogmios doesn't support it
        # "x86_64-darwin"
        # we don't have a builder
        # "aarch64-darwin"
      ];
    };
}
