{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cardano.monitoring;
  inherit (lib) mkIf mkEnableOption mkMerge mkOption types;
in {
  options.cardano.monitoring = {
    enable = mkEnableOption ''
      monitoring services Prometheus and Grafana
    '';
    targets = mkOption {
      type = with types; listOf string;
      default = ["localhost"];
      description = ''
        List of hosts to to scrape prometheus metrics from.
      '';
    };
    exporters = {
      enable = mkOption {
        type = with types; bool;
        default = cfg.enable;
        description = ''
          Enable Prometheus exporters for running services.
        '';
      };
      ports = mkOption {
        type = with types; listOf port;
        default = [
          config.services.prometheus.exporters.node.port
          config.services.prometheus.exporters.nginx.port
          12798 # cardano-node
          config.services.ogmios.port
          config.services.blockfrost.settings.server.port
          config.services.prometheus.exporters.postgres.port
        ];
        description = ''
          List of ports where prometheus exporters are exposed. This can be used to open ports in the firewall.
        '';
      };
      openFirewall = mkOption {
        type = with types; bool;
        default = cfg.exporters.enable;
        description = ''
          Open firewall ports for prometheus exporters.
        '';
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
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
          {
            job_name = "cardano-node";
            static_configs = [{targets = map (target: "${target}:12798") cfg.targets;}];
          }
          {
            job_name = "ogmios";
            static_configs = [{targets = map (target: "${target}:${builtins.toString config.services.ogmios.port}") cfg.targets;}];
          }
          {
            job_name = "blockfrost";
            static_configs = [{targets = map (target: "${target}:${builtins.toString config.services.blockfrost.settings.server.port}") cfg.targets;}];
          }
          {
            job_name = "postgres";
            static_configs = [{targets = map (target: "${target}:${builtins.toString config.services.prometheus.exporters.postgres.port}") cfg.targets;}];
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
              name = "Dashboards";
              options.path = "/etc/grafana-dashboards";
            }
          ];
        };
      };

      environment.etc = {
        "grafana-dashboards/node.json" = {
          user = "grafana";
          group = "grafana";
          source = pkgs.fetchurl {
            url = "https://grafana.com/api/dashboards/1860/revisions/37/download";
            sha256 = "sha256-1DE1aaanRHHeCOMWDGdOS1wBXxOF84UXAjJzT5Ek6mM=";
          };
        };
        "grafana-dashboards/nginx.json" = {
          user = "grafana";
          group = "grafana";
          source = pkgs.fetchurl {
            url = "https://grafana.com/api/dashboards/14900/revisions/2/download";
            sha256 = "sha256-9iOEwKdFxOyw2T7Non4k2yUwiajWpH3qgQTyJRrttwM=";
          };
        };
        "grafana-dashboards/postgres.json" = {
          user = "grafana";
          group = "grafana";
          source = pkgs.fetchurl {
            url = "https://grafana.com/api/dashboards/9628/revisions/7/download";
            sha256 = "sha256-xkzDitnr168JVR7oPmaaOPYqdufICSmvVmilhScys3Y=";
          };
        };
      };
    })
    (mkIf cfg.exporters.enable {
      services.prometheus.exporters = {
        node.enable = true;
        nginx.enable = config.services.nginx.enable;
        postgres.enable = config.services.postgresql.enable;
      };
      services.cardano-node = mkIf config.services.cardano-node.enable {
        extraNodeConfig.hasPrometheus = ["0.0.0.0" 12798];
      };
      services.blockfrost = mkIf config.services.bockfrost.enable or false {
        settings.server.prometheusMetrics = true;
      };
    })
    (mkIf cfg.exporters.openFirewall {
      networking.firewall.allowedTCPPorts = cfg.exporters.ports;
    })
  ];
}
