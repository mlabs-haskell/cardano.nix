{lib, ...}: let
  lib' = import ./functions.nix lib;
in {
  options.cardanoNix = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.submodule;
  };
  config.flake.lib = lib';
}
