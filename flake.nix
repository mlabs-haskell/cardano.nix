{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # we use effects for CI and documentation
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";

    # Cardano
    cardano-node.url = "github:intersectmbo/cardano-node?ref=8.7.3";
    iohk-nix.follows = "cardano-node/iohkNix";

    # Reduce stackage.nix source download deps
    haskell-nix.follows = "cardano-node/haskellNix";
    haskell-nix.inputs.stackage.follows = "empty-flake";
    empty-flake.url = "github:input-output-hk/empty-flake";

    # Utilities
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-root.url = "github:srid/flake-root";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devour-flake = {
      url = "github:srid/devour-flake";
      flake = false;
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs"; # Prevent download unnessesary nixpkgs
    };
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {
      inherit inputs;
    } {
      debug = true;
      imports = [
        ./lib
        ./checks
        ./ci
        ./docs
        ./formatter
        ./modules
        ./packages
        ./shell
        ./tests
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    };
}
