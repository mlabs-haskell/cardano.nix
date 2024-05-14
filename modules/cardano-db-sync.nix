{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.cardano.db-sync;
  dbsync-cfg = config.services.cardano-db-sync;
in {
  options.cardano.db-sync = with types; {
    enable = mkEnableOption ''
      Cardano DB Sync provides a way to query local cardano node.

      Cardano DB sync connects to a cardano node and saves blocks to a database.
      You need to either provide the db connection arguments:
        ```nix
        services.cardano-db-sync.database = {
          # these are the defaults:
          name = "cdbsync";
          user = "cdbsync";
          port = 5432;
          socketdir = "/run/postgresql";
        };
        ```
      or enable the default postgresql service with `services.cardano-db-sync.postgres.enable` and possibly overwrite the `services.postgresql` options for your need.
    '';
    postgres.enable = mkEnableOption "Run postgres and connect dbsync to it." // {default = true;};
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.cardano-db-sync = {
        enable = true;
        environment = config.services.cardano-node.environments.${config.cardano.network};
        inherit (config.cardano.node) socketPath;
        postgres = {
          user = "cdbsync";
          # use first socket from postgresql settings or default to /run/postgresql
          socketdir = builtins.head ((config.services.postgresql.settings.unix_socket_directories or []) ++ ["/run/postgresql"]);
          port = config.services.postgresql.settings.port or 5432;
          database = "cdbsync";
        };
        stateDir = "/var/lib/${dbsync-cfg.postgres.user}";
      };
      systemd.services.cardano-db-sync = {
        serviceConfig = {
          DynamicUser = true;
          User = dbsync-cfg.postgres.user;
          # Security
          UMask = "0077";
          CapabilityBoundingSet = "";
          ProtectClock = true;
          ProtectKernelLogs = true;
          ProtectDevices = true;
          ProtectKernelModules = true;
          SystemCallArchitectures = "native";
          MemoryDenyWriteExecute = true;
          RestrictNamespaces = true;
          ProtectHostname = true;
          ProtectKernelTunables = true;
          RestrictRealtime = true;
          SystemCallFilter = ["@system-service" "~@privileged"];
          PrivateDevices = true;
          RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
          IPAddressAllow = "localhost";
          IPAddressDeny = "any";
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
      };
    }
    (mkIf (config.cardano.node.enable or false) {
      systemd.services.cardano-db-sync = {
        after = ["cardano-node-socket.service"];
        requires = ["cardano-node-socket.service"];
      };
    })
    (mkIf cfg.postgres.enable {
      services.postgresql = {
        enable = true;
        # see warnings: this should be same as user name
        ensureDatabases = [dbsync-cfg.postgres.database];
        ensureUsers = [
          {
            name = "${dbsync-cfg.postgres.database}";
            ensureDBOwnership = true;
          }
        ];
      };
      warnings =
        if (dbsync-cfg.postgres.database != dbsync-cfg.postgres.user)
        then [
          "When postgres is enabled, we use the ensureDBOwnership option which expects the user name to match db name."
        ]
        else [];
    })
  ]);
}
