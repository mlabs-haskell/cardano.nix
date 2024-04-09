{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.cardano.cardano-db-sync;
in {
  options.cardano.cardano-db-sync = with types; {
    enable = mkEnableOption "Cardano DB Sync provides a way to query local cardano node.";
    postgres.database = mkOption {
      type = str;
      default = "cdbsync";
      description = "Used for postgresql database and the cardano-db-sync service user.";
    };
    # `services.cardano-db-sync` module options:
    explorerConfig = mkOption {
      type = attrs;
      default = cfg.environment.dbSyncConfig;
    };
    logConfig = mkOption {
      type = attrs;
      default = {};
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

  config = mkIf cfg.enable {
    services.cardano-db-sync = {
      enable = true;
      environment = config.services.cardano-node.environments.${config.cardano.network};
      inherit (config.cardano.node) socketPath;
      postgres = {
        inherit (config.services.postgresql) port;
        inherit (cfg.postgres) database;
        user = cfg.postgres.database;
        socketdir = "/var/run/postgresql";
      };
      inherit (cfg) explorerConfig;
      inherit (cfg) logConfig;
      inherit (cfg) disableLedger;
      inherit (cfg) takeSnapshot;
      inherit (cfg) restoreSnapshot;
      inherit (cfg) restoreSnapshotSha;
    };
    services.postgresql = {
      enable = true;
      ensureDatabases = [cfg.postgres.database];
      ensureUsers = [
        {
          name = "${cfg.postgres.database}";
          ensureDBOwnership = true;
        }
      ];
    };
    # users.users = {
    #   "${cfg.postgres.database}" = {
    #     group = "${cfg.postgres.database}";
    #     isSystemUser = true;
    #   };
    # };
    # users.groups."${cfg.postgres.database}" = {};
    systemd.services.cardano-db-sync = mkIf (config.cardano.node.enable or false) {
      after = ["cardano-node-socket.service"];
      requires = ["cardano-node-socket.service"];
      serviceConfig = {
        DynamicUser = true;
        User = cfg.postgres.database;
      };
    };
    assertions = [
      {
        assertion = config.cardano.node.enable;
        message = "Cardano db sync requires `cardano.node.enable`.";
      }
    ];
  };
}