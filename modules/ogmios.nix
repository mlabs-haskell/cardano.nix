{
  config,
  lib,
  ...
}: let
  cfg = config.cardanoNix.ogmios;
in {
  options.cardanoNix.ogmios = {
    enable = lib.mkEnableOption "Ogmios bridge interface for cardano-node";
  };

  config = lib.mkIf cfg.enable {
    services.ogmios = {
      enable = true;
      nodeConfigPath =
        lib.mkIf (config.cardanoNix.cardano-node.enable or false)
        config.cardanoNix.cardano-node.configPath;
    };

    systemd.services.ogmios = lib.mkIf (config.cardanoNix.cardano-node.enable or false) {
      after = ["cardano-node-socket.service"];
      requires = ["cardano-node-socket.service"];
    };
  };
}
