{
  config,
  lib,
  ...
}: {
  config = {
    flake.lib = import ./functions.nix lib;
    _module.args.lib' = config.lib;
    perSystem = {
      _module.args = {
        rootConfig = config;
        lib' = config.lib;
      };
    };
  };
}
