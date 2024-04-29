{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.cardano.cardano-db-sync;
in {
  options.cardano.cardano-db-sync = with types; {
    enable = mkEnableOption ''
      Cardano DB Sync provides a way to query local cardano node.

      Cardano DB sync connects to a cardano node and saves blocks to a database.
      You need to either provide the db connection arguments:
        ```
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
    postgres = {
      enable = mkEnableOption "Run postgres and connect dbsync to it.";
    };
    database = {
      name = mkOption {
        type = str;
        default = "cdbsync";
        description = "Postgres database name.";
      };
      user = mkOption {
        type = str;
        default = "cdbsync";
        description = "Postgres database user.";
      };
      port = mkOption {
        type = int;
        default =
          if cfg.postgres.enable
          then config.services.postgresql.settings.port
          else 5432;
        description = "Postgres database port. See also option socketDir `cardano.cardano-db-sync.database.socketdir`.";
      };
      socketdir = lib.mkOption {
        type = lib.types.str;
        default = "/run/postgresql";
        description = "Path to the postgresql socket.";
      };
    };
    _environment = mkOption {
      default = config.services.cardano-node.environments.${config.cardano.network} or {hack = "<Cardano envirionment attribute set>";};
      internal = true;
      type = attrs;
      description = "Attribute set describing the chosen network (mainnet, testnet, etc.). By default taken from `services.cardano-node.environments`.";
    };
    # `services.cardano-db-sync` module options:
    explorerConfig = mkOption {
      type = attrs;
      default = cfg._environment.dbSyncConfig or {hack = "Should be cfg._environment.dbSyncConfig";};
      description = "Together with logConfig constructs the db-sync config file.";
    };
    logConfig = mkOption {
      type = attrs;
      default = {};
      description = "Together with explorerConfig constructs the db-sync config file.";
    };
    disableLedger = mkOption {
      type = bool;
      default = false;
      description = ''
        Disables the leger state. Drastically reduces memory usage
        and it syncs faster, but some data are missing.
      '';
    };
    takeSnapshot = mkOption {
      type = enum ["never" "once" "always"];
      default = "never";
      description = ''
        Take snapshot before starting cardano-db-sync,
                  "once" (skip if there is one already),
                  "always" (removing previous snapshot),
                  or "never".
      '';
    };
    restoreSnapshot = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        Restore a snapshot before starting cardano-db-sync,
        if the snasphot file given by the option exist.
        Snapshot file is deleted after restore.
      '';
    };
    restoreSnapshotSha = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        SHA256 checksum of the snapshot to restore
      '';
    };
  };

  config = let
    inherit (cfg.postgres) database;
  in
    mkIf cfg.enable (mkMerge [
      {
        services.cardano-db-sync = {
          enable = true;
          environment = cfg._environment;
          inherit (config.cardano.node) socketPath;
          postgres = {
            inherit (cfg.database) user socketdir port;
            database = cfg.database.name;
          };
          stateDir = "/var/lib/${cfg.database.name}";
          inherit (cfg) explorerConfig logConfig disableLedger takeSnapshot restoreSnapshot restoreSnapshotSha;
        };
        systemd.services.cardano-db-sync = mkIf (config.cardano.node.enable or false) {
          after = ["cardano-node-socket.service"];
          requires = ["cardano-node-socket.service"];
          serviceConfig = {
            DynamicUser = true;
            User = cfg.database.user;
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
        assertions = [
          {
            assertion = config.cardano.node.enable;
            message = "Cardano db sync requires `cardano.node.enable`.";
          }
          {
            assertion = (! cfg.postgres.enable) || (cfg.database.name == cfg.database.user);
            message = "When postgres is enabled, we use the ensureDBOwnership option which expects the user name to match db name.";
          }
        ];
      }
      (mkIf cfg.postgres.enable {
        services.postgresql = {
          enable = true;
          # see assertions: this is same as user name
          ensureDatabases = [cfg.database.name];
          ensureUsers = [
            {
              name = "${cfg.database.name}";
              ensureDBOwnership = true;
            }
          ];
          authentication =
            # type database  DBuser      auth-method optional_ident_map
            ''
              local sameuser ${cfg.database.name} peer
            '';
        };
      })
    ]);
}
