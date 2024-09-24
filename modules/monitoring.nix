{
  config,
  lib,
  ...
}: let
  cfg = config.cardano.monitoring;
  inherit (lib) mkIf mkEnableOption mkOption types;
in {
  options.cardano.monitoring = {
    enable = mkEnableOption ''
      monitoring via Prometheus and Grafana
    '';
    targets = mkOption {
      type = with types; listOf string;
      default = ["localhost"];
      description = ''
        List of hosts to to scrape prometheus metrics from.
      '';
    };
  };
  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{targets = map (target: "${target}:${builtins.toString config.services.prometheus.exporters.node.port}") cfg.targets;}];
        }
        {
          job_name = "nginx";
          static_configs = [{targets = map (target: "${target}:${builtins.toString config.services.prometheus.exporters.nginx.port}") cfg.targets;}];
        }
      ];
    };

    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "0.0.0.0";
        };
      };
      provision = {
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            uid = "local_prometheus";
            url = "http://localhost:${builtins.toString config.services.prometheus.port}";
          }
        ];
        dashboards.settings.providers = [
          {
            name = "node";
            options.path = ./monitoring/node.json;
          }
          {
            name = "nginx";
            options.path = ./monitoring/nginx.json;
          }
        ];
      };
    };
  };
}
