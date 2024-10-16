{
  config,
  lib,
  ...
}: let
  cfg = config.services.http-proxy;
  inherit (lib) types listToAttrs mkOption mkEnableOption mapAttrs mkIf optional optionalString;
in {
  options.services.http-proxy = {
    enable = mkEnableOption "HTTP reverse proxy, TLS endpoint and load balancer";
    openFirewall = mkOption {
      description = "Open firewall for HTTP and HTTPS.";
      type = types.bool;
      default = true;
    };
    domainName = mkOption {
      description = "Domain name. For each service a virtualHost is configured as a subdomain.";
      type = types.str;
      default = "";
    };
    https.enable = mkOption {
      description = "Enable TLS and redirect all connections to HTTPS. Requires certificates. Supports ACME.";
      type = types.bool;
      default = false;
    };
    https.acme.enable = mkOption {
      description = "Enable Let's Encrypt ACME TLS certificates. Requires public DNS records pointing to server and `security.acme` configured.";
      type = types.bool;
      default = cfg.https.enable;
    };
    servers = mkOption {
      description = "List of upstream server host names used for all services.";
      type = types.listOf types.str;
      default = [];
    };
    services = mkOption {
      description = "Configuraiton for each upstream service.";
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          name = mkOption {
            description = "Name of the service.";
            type = types.str;
            default = name;
          };
          servers = mkOption {
            description = "List of upstream server host names.";
            type = types.listOf types.str;
            default = cfg.servers;
          };
          port = mkOption {
            description = "Upstream server port.";
            type = types.nullOr types.port;
            default = null;
          };
          version = mkOption {
            description = "This string will be served at path '/version'.";
            type = types.nullOr types.str;
            default = null;
          };
        };
      }));
    };
    _mkUpstream = mkOption {
      type = types.functionTo types.attrs;
      internal = true;
      default = service: {
        servers = listToAttrs (map
          (server: {
            name = "${server}:${toString service.port}";
            value = {};
          })
          service.servers);
      };
    };
    _mkVirtualHost = mkOption {
      type = types.functionTo types.attrs;
      internal = true;
      default = service: {
        serverName = "${service.name}${optionalString (cfg.domainName != "") ".${cfg.domainName}"}";
        forceSSL = cfg.https.enable;
        enableACME = cfg.https.acme.enable;
        locations = {
          "=/version" = mkIf (service.version != null) {
            return = "200 ${service.version}";
            extraConfig = "add_header Content-Type text/plain;";
          };
          "/" = mkIf (service.port != null) {
            proxyWebsockets = true;
            proxyPass = "http://${service.name}";
          };
        };
        extraConfig = "
          proxy_hide_header Access-Control-Allow-Origin;
          add_header Access-Control-Allow-Origin * always;
          proxy_hide_header Access-Control-Allow-Headers;
          add_header Access-Control-Allow-Headers * always;
          proxy_hide_header Access-Control-Allow-Methods;
          add_header Access-Control-Allow-Methods * always;
        ";
      };
    };
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall ([80] ++ optional cfg.https.enable 443);

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      serverNamesHashBucketSize = 128;

      statusPage = true;

      upstreams = mapAttrs (_: cfg._mkUpstream) (lib.filterAttrs (_: s: s.port != null) cfg.services);
      virtualHosts = mapAttrs (_: cfg._mkVirtualHost) cfg.services;
    };
  };
}
