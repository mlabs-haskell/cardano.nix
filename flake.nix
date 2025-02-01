{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    # Services

    "cardano-node" = {
      url = "github:intersectmbo/cardano-node/10.1.4";
    };
    cardano-db-sync = {
      url = "github:intersectmbo/cardano-db-sync/13.6.0.1";
    };
    blockfrost = {
      url = "github:blockfrost/blockfrost-backend-ryo/v3.1.0";
    };
    oura = {
      url = "github:txpipe/oura/v1.9.2";
      inputs.crane.follows = "crane";
    };
    crane = {
      url = "github:ipetkov/crane";
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
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
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
      flake.templates = {
        default = {
          path = ./templates/default;
          description = "Example flake using cardano.nix";
        };
        cluster = {
          path = ./templates/cluster;
          description = "Example flake for deploying a cardano.nix cluster with multiple nodes, load balancer and monitoring";
        };
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
