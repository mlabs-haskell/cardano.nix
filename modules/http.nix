{
  config,
  lib,
  ...
}: let
  cfg = config.cardano.http;
  inherit (lib) mkIf mkEnableOption optional;
in {
  options.cardano.http = {
    enable =
      mkEnableOption "HTTP SSL proxy and load balancer for cardano services"
      // {default = config.cardano.enable or false;};
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80] ++ optional config.services.http-proxy.https.enable 443;

    services.http-proxy = {
      enable = true;
      servers = mkIf config.cardano.enable ["127.0.0.1"];
      services = {
        cardano-node = {
          inherit (config.services.cardano-node) port;
          inherit (config.services.cardano-node.package.passthru.identifier) version;
        };
        ogmios = {
          inherit (config.services.ogmios) port;
          inherit (config.services.ogmios.package) version;
        };
        kupo = {
          inherit (config.services.kupo) port;
          inherit (config.services.kupo.package) version;
        };
      };
    };
  };
}
