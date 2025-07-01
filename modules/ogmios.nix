{
  config,
  lib,
  ...
}:
let
  cfg = config.cardano.ogmios;
in
{
  options.cardano.ogmios = {
    enable = lib.mkEnableOption "Ogmios bridge interface for cardano-node";
  };

  config = lib.mkIf cfg.enable {
    services.ogmios = {
      enable = true;
      nodeSocketPath = lib.mkIf (config.cardano.node.enable or false) config.cardano.node.socketPath or null;
    };

    systemd.services.ogmios = lib.mkIf (config.cardano.node.enable or false) {
      after = [ "cardano-node-socket.service" ];
      requires = [ "cardano-node-socket.service" ];
    };
  };
}
