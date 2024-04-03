{
  config,
  lib,
  ...
}: let
  cfg = config.cardano.ogmios;
in {
  options.cardano.ogmios = {
    enable = lib.mkOption {
      description = "Whether to enable the Ogmios bridge interface for cardano-node.";
      type = lib.types.bool;
      default = config.cardano.enable or false;
    };
  };

  config = lib.mkIf cfg.enable {
    services.ogmios = {
      enable = true;
      nodeConfigPath =
        lib.mkIf (config.cardano.node.enable or false)
        config.cardano.node.configPath or null;
    };

    systemd.services.ogmios = lib.mkIf (config.cardano.node.enable or false) {
      after = ["cardano-node-socket.service"];
      requires = ["cardano-node-socket.service"];
    };
  };
}
