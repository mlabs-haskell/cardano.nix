{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # cardano-node
    cardano-node.url = "github:intersectmbo/cardano-node?ref=8.7.3";

    # Utilities
    attic.url = "github:zhaofengli/attic";
    devour-flake.url = "github:srid/devour-flake";
    devour-flake.flake = false;
    devshell.url = "github:numtide/devshell";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    hercules-ci-effects.url = "github:mlabs-haskell/hercules-ci-effects/push-cache-effect";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # Prevent unnecessary downloads
    attic.inputs.nixpkgs.follows = "nixpkgs";
    attic.inputs.nixpkgs-stable.follows = "nixpkgs";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    hercules-ci-effects.inputs.nixpkgs.follows = "nixpkgs";
    hercules-ci-effects.inputs.flake-parts.follows = "flake-parts";
    pre-commit-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks-nix.inputs.nixpkgs-stable.follows = "nixpkgs";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
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
        ./shell
        ./tests
        ./packages
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        # Ogmios doesn't support it
        # "x86_64-darwin"
        "aarch64-darwin"
      ];
    };
}
