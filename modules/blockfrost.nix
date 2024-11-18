{
  config,
  lib,
  ...
}:
let
  cfg = config.cardano.blockfrost;
  dbsync-cfg = config.services.cardano-db-sync or null;
  inherit (lib) mkIf mkMerge mkEnableOption;
in
{
  options.cardano.blockfrost = {
    enable = mkEnableOption ''
      Blockfrost.io backend is an API service providing abstraction between you and Cardano blockchain data

      Blockfrost connects to a postgresql database, populated by Cardano DB sync with node.
      You need to either provide the db connection arguments:
        ```nix
        services.blockfrost.settings.dbSync = {
          # these are the defaults:
          name = "cardano-db-sync";
          user = "cardano-db-sync";
          port = 5432;
          # optionally supply "host" and "password" parameters.
          socketdir = "/run/postgresql";
        };
        ```
      or enable the default postgresql service with `cardano.blockfrost.postgres.enable`
    '';

    postgres.enable = mkEnableOption "Connect blockfrost to local postgresql." // {
      default = true;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.blockfrost = {
        enable = true;
        settings = {
          inherit (config.cardano) network;
        };
      };
      systemd.services.blockfrost-backend-ryo.serviceConfig = {
        # Security
        UMask = "0077";
        CapabilityBoundingSet = "";
        ProtectClock = true;
        ProtectKernelLogs = true;
        ProtectDevices = true;
        ProtectKernelModules = true;
        SystemCallArchitectures = "native";
        RestrictNamespaces = true;
        ProtectHostname = true;
        ProtectKernelTunables = true;
        RestrictRealtime = true;
        # TODO: Find the most restricting systemCallFilter
        PrivateDevices = true;
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
        ProtectHome = true;
        DevicePolicy = "closed";
        DeviceAllow = "";
        ProtectProc = "invisible";
        ProcSubset = "pid";
        PrivateTmp = true;
        ProtectControlGroups = true;
        PrivateUsers = true;
        LockPersonality = true;
      };
    }
    (mkIf cfg.postgres.enable {
      services.postgresql = {
        identMap = ''
          users ${config.services.blockfrost.user} ${config.services.cardano-db-sync.postgres.user}
          users postgres postgres
        '';
        authentication = ''
          local all all ident map=users
        '';
      };
      services.blockfrost.settings = {
        dbSync = {
          inherit (dbsync-cfg.postgres) user port database;
          host = dbsync-cfg.postgres.socketdir; # Required, to force connect by local socket, as well as local auth
        };
      };
      assertions = [
        {
          assertion = cfg.postgres.enable && (config.cardano.db-sync.enable or false) && (config.services.postgresql.enable or false);
          message = "`config.blockfrost.postgres.enabled` require enabling `config.cardano.db-sync.enable` and `config.services.postgresql.enabled` to work.";
        }
      ];
    })
    (mkIf (config.cardano.node.enable or false) {
      systemd.services.blockfrost-backend-ryo = {
        after = [ "cardano-node-socket.service" ];
        requires = [ "cardano-node-socket.service" ];
      };
    })
    (mkIf (config.cardano.db-sync.enable or false) {
      systemd.services.blockfrost-backend-ryo = {
        after = [ "cardano-db-sync.service" ];
        requires = [ "cardano-db-sync.service" ];
      };
    })
  ]);
}
