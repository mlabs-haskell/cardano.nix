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
      lib.mkEnableOption ''connect oura to local cardano-node via N2C''
      // {default = config.cardano.node.enable or false;};

    prometheusExporter.enable =
      lib.mkEnableOption "prometheus exporter";

    prometheusExporter.port = lib.mkOption {
      description = "Port where Prometheus exporter is exposed.";
      type = lib.types.port;
      default = 9186;
    };
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
        metrics.address = lib.mkIf cfg.prometheusExporter.enable "0.0.0.0:${builtins.toString cfg.prometheusExporter.port}";
      };
    };

    systemd.services.oura = lib.mkIf (config.cardano.node.enable or false) {
      after = ["cardano-node-socket.service"];
      requires = ["cardano-node-socket.service"];
    };
  };
}
