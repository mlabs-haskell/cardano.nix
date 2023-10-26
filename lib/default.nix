{inputs, ...}: let
  lib = import ./functions.nix inputs.nixpkgs.lib;
in {
  flake.lib = lib;
}
