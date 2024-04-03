{
  config,
  lib,
  ...
}: let
  cfg = config.cardano.http;
  inherit (lib) types last mkIf mkOption optional splitString;
in {
  options.cardano.http = {
    enable = mkOption {
      description = "Whether to enable HTTP SSL proxy and load balancer for cardano services.";
      type = types.bool;
      default = config.cardano.enable or false;
    };
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80] ++ optional config.services.http-proxy.https.enable 443;

    services.http-proxy = {
      enable = true;
      servers = mkIf config.cardano.enable ["127.0.0.1"];
      services = {
        cardano-node = {
          inherit (config.services.cardano-node) port;
          version = last (splitString " " config.services.cardano-node.package);
        };
        ogmios = {
          inherit (config.services.ogmios) port;
          inherit (config.services.ogmios.package) version;
        };
      };
    };
  };
}
