{
  config,
  lib,
  ...
}: let
  cfg = config.cardano.kupo;
in {
  options.cardano.kupo = {
    enable =
      lib.mkEnableOption "Kupo chain-indexer";
  };

  config = lib.mkIf cfg.enable {
    services.kupo = {
      enable = true;
      nodeSocketPath =
        lib.mkIf (config.cardano.node.enable or false)
        config.cardano.node.socketPath;
      nodeConfigPath =
        lib.mkIf (config.cardano.node.enable or false)
        config.cardano.node.configPath;
      ogmiosHost =
        lib.mkIf (config.cardano.ogmios.enable or false)
        "127.0.0.1";
      ogmiosPort =
        lib.mkIf (config.cardano.ogmios.enable or false)
        config.services.ogmios.port;
    };

    systemd.services.kupo = {
      after =
        lib.optional (config.cardano.node.enable or false) "cardano-node-socket.service"
        ++ lib.optional (config.cardano.ogmios.enable or false) "ogmios.service";
      requires =
        lib.optional (config.cardano.node.enable or false) "cardano-node-socket.service"
        ++ lib.optional (config.cardano.ogmios.enable or false) "ogmios.service";
    };
  };
}
