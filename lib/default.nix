{config, lib, ...}: let
  lib' = import ./functions.nix lib;
in {
  config = {
    flake.lib = lib';
    perSystem = {
      _module.args.rootConfig = config;
    };
  };
}
