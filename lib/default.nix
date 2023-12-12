{
  config,
  lib,
  ...
}: {
  config = {
    flake.lib = import ./functions.nix lib;
    perSystem = {
      _module.args.rootConfig = config;
    };
  };
}
