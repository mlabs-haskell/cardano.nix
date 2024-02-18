{
  cardanoNixInternals,
  lib,
  ...
}: let
  inherit (cardanoNixInternals) self';
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
        cardano-lib = mkOption {
          type = path;
          default = self'.packages.cardano-lib;
          description = ''
            Library of default cardano configurations
          '';
        };
      };
    };
    description = "FIXME";
  };
  config = {
    cardanoNix.packages = lib.mkDefault {};
  };
}
