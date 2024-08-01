{
  config,
  lib,
  ...
}: let
  cfg = config.cardano.oura;
in {
  options.cardano.oura = {
    enable =
      lib.mkEnableOption "Oura"
      // {default = config.cardano.enable or false;};
    integrate =
      lib.mkEnableOption ''
        connect oura to local cardano-node via N2C
      ''
      // {default = config.cardano.node.enable or false;};
  };

  config = lib.mkIf cfg.enable {
    services.oura = {
      enable = true;
      settings = {
        source = lib.mkIf cfg.integrate {
          type = "N2C";
          address = ["Unix" config.cardano.node.socketPath];
          magic = config.cardano.network;
        };
      };
    };

    systemd.services.oura = lib.mkIf (config.cardano.node.enable or false) {
      after = ["cardano-node-socket.service"];
      requires = ["cardano-node-socket.service"];
    };
  };
}
