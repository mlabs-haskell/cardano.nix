{
  config,
  lib,
  ...
}: let
  cardanoTypes = import ./types.nix {inherit lib;};
  inherit (lib) types mkOption mkEnableOption mkIf recursiveUpdate;
  inherit (types) str;
  inherit (cardanoTypes) shelleyEraKeysType generateShelleyKeysOptions;
  cfg = config.cardanoNix.cardano-node.producer;
  inherit (config.cardanoNix.cardano-node) defaults;
in {
  options = {
    # NOTE: This is user facing option set, keep it simple and strongly typed
    cardanoNix.cardano-node.producer = {
      enabled = mkEnableOption "producer";

      name = mkOption {
        type = types.str;
        default = "producer";
      };

      # FIXME: does it producer specific?
      shelleyEraKeys = mkOption {
        type = shelleyEraKeysType;
      };
    };
  };

  config = mkIf cfg.enabled {
    cardanoNix.cardano-node.instances.${cfg.name} = recursiveUpdate defaults {
      options =
        {
          # Some local options here
        }
        // generateShelleyKeysOptions cfg.shelleyEraKeys;
    };
  };
}
