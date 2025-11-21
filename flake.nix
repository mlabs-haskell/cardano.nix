{
  # Utilities
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs_";
    };

    flake-root.url = "github:srid/flake-root";

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat_";
      };
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hercules-ci-effects = {
      url = "github:mlabs-haskell/hercules-ci-effects/push-cache-effect";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    crane.url = "github:ipetkov/crane";

    devour-flake = {
      url = "github:srid/devour-flake";
      flake = false;
    };
  };

  # Services
  inputs = {
    cardano-node.url = "github:intersectmbo/cardano-node/10.5.2"; # following `nixpkgs_` doesn'work

    cardano-db-sync = {
      url = "github:intersectmbo/cardano-db-sync/13.6.0.5";
      inputs = {
        nixpkgs.follows = "cardano-node/nixpkgs"; # following `nixpkgs_` doesn't work
        utils.follows = "flake-utils_";
        hackageNix.follows = "hackageNix_";
        iohkNix.follows = "iohkNix_";
        flake-compat.follows = "flake-compat_";
      };
    };

    blockfrost = {
      url = "github:blockfrost/blockfrost-backend-ryo/v4.1.2";
      # inputs.nixpkgs.follows = "nixpkgs_";  # FIXME do this when https://github.com/blockfrost/blockfrost-backend-ryo/issues/279 is merged
    };

    oura = {
      url = "github:txpipe/oura/v1.9.4";
      inputs = {
        utils.follows = "flake-utils_";
        crane.follows = "crane_";
      };
    };

    demeter-run-cli = {
      url = "github:demeter-run/cli";
      flake = false;
    };
  };

  # Shared inputs for deduplication
  inputs = {
    nixpkgs_.follows = "nixpkgs";
    hackageNix_.follows = "cardano-node/hackageNix";
    iohkNix_.follows = "cardano-node/iohkNix";
    flake-utils_.follows = "cardano-node/utils";
    flake-compat_.follows = "cardano-node/flake-compat";
    crane_.follows = "crane";
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
        ./templates
      ];
      systems = [ "x86_64-linux" ];
    };
}
