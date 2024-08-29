{
  config,
  lib,
  ...
}: let
  cfg = config.cardano.http;
  inherit (lib) mkIf mkDefault mkEnableOption optional;
in {
  options.cardano.http = {
    enable = mkEnableOption ''
      HTTP SSL proxy and load balancer for cardano services

      This option has the following effects:
      - set `networking.firewall.allowedTCPPorts` to open port 80, and if `https` is enabled, port 443 as well
      - set `services.http-proxy.enable` to `true`, see the documentation for that option
      - set `services.http-proxy.services.{ogmios,kupo}.{port,version}` in order to automatically forward these services
      - set `services.http-proxy.services.cardano-node.version` to expose version
      - if either `cardano.{ogmios,kupo}.enable` is true, set `services.http-proxy.servers` to `mkDefault [ "127.0.0.1" ]`
    '';
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80] ++ optional config.services.http-proxy.https.enable 443;

    services.http-proxy = {
      enable = true;
      servers = mkIf (config.cardano.ogmios.enable || config.cardano.kupo.enable) (mkDefault ["127.0.0.1"]);
      services = {
        cardano-node = {
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
