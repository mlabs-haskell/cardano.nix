{lib, ...}: let
  lib' = import ./functions.nix lib;
in {
  flake.lib = lib';
}
