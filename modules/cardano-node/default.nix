{
  config,
  lib,
  ...
}: let
  cfg = config.cardanoNix.cardano-node;
in {
  options.cardanoNix.cardano-node = {
    enable = lib.mkEnableOption "cardano-node service";
  };

  config = lib.mkIf cfg.enable {
    environment.variables = {
      CARDANO_NODE_SOCKET_PATH = config.services.cardano-node.socketPath 0;
    };

    services.cardano-node = {
      enable = true;
      hostAddr = "0.0.0.0";

      environment = config.cardanoNix.globals.network;
    };
  };
}
