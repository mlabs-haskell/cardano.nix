{
  config,
  lib,
  ...
}: let
  cfg = config.cardano.ogmios;
in {
  options.cardano.ogmios = {
    enable = lib.mkEnableOption "cardano-node service";
  };

  config = lib.mkIf cfg.enable {
    services.ogmios = {
      enable = true;
      nodeConfigPath =
        lib.mkIf (config.cardano.node.enable or false)
        config.cardano.node.configPath;
    };

    systemd.services.ogmios = lib.mkIf (config.cardano.node.enable or false) {
      after = ["cardano-node-socket.service"];
      requires = ["cardano-node-socket.service"];
    };
  };
}
