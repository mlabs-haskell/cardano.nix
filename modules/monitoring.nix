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
      Monitoring via Prometheus and Grafana
    '';
  };
  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;

      # scrapeConfigs = { };

      webExternalUrl = "https://prometheus.${config.networking.hostName}.${config.networking.domainName}";

      alertmanager = {
        enable = true;
        webExternalUrl = "https://alerts.${config.networking.hostName}.${config.networking.domainName}";
      };
    };

    services.grafana = {
      enable = true;
      settings = {
        server = {
          domain = "status.staging.mlabs.city";
          http_addr = "127.0.0.1";
          http_port = 2342;
          root_url = "https://${config.services.grafana.settings.server.domain}:443/";
        };
        security = {
          admin_user = "admin";
          admin_password = "CHANGEME_uDZ2isTf";
        };
      };
    };
  };
}
