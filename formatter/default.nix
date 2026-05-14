{ inputs, ... }:
{
  imports = [
    inputs.flake-root.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      treefmt.config = {
        inherit (config.flake-root) projectRootFile;
        package = pkgs.treefmt;
        flakeFormatter = true;
        flakeCheck = true;
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          prettier.enable = true;
          statix.enable = true;
        };
        settings.formatter.nixfmt.options = [ "--width=65536" ];

        # Exclude vendored cardano-node-service from formatting
        # https://github.com/IntersectMBO/cardano-node/pull/6528
        settings.excludes = [ "modules/services/cardano-node-service.nix" ];
      };

      devshells.default.commands = [
        {
          category = "tools";
          name = "fmt";
          help = "format the source tree";
          command = lib.getExe config.treefmt.build.wrapper;
        }
      ];
    };
}
