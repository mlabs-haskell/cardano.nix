{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf types;
  cfg = config.cardanoNix.cardano-node.producer;
in {
  options = {
    cardanoNix.cardano-node.relay = {
      enabled = mkEnableOption "producer";

      name = mkOption {
        type = types.str;
        default = "relay";
      };
    };
  };

  config = mkIf cfg.enabled {
    cardanoNix.cardano-node.instances.${cfg.name} = {
      options = {
        someProducerOption = "42";
      };
    };
  };
}
