{
  self',
  lib,
  ...
}: let
  inherit (lib) types mkOption;
  inherit (types) path submodule;
in {
  options.cardanoNix.packages = mkOption {
    type = submodule {
      options = {
        cardano-node = mkOption {
          type = path;
          description = ''
            Default package for cardano-node
          '';
          default = self'.packages.cardano-node;
          internal = true;
        };
        cardano-cli = mkOption {
          type = path;
          description = ''
            Default package for cardano-cli
          '';
          default = self'.packages.cardano-cli;
          internal = true;
        };
      };
    };
    description = "FIXME";
  };
}
