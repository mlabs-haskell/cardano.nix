{
  config,
  lib,
  ...
}: let
  cfg = config.cardano.blockfrost;
  dbsync-cfg = config.services.cardano-db-sync;
  inherit (lib) mkIf mkMerge mkEnableOption;
in {
  options.cardano.blockfrost =
    {
      enable =
        mkEnableOption ''
        '';
    }
    // {default = config.cardano.enable or false;};

  config = mkIf cfg.enable (mkMerge [
    {
      services.blockfrost = {
        enable = true;
        settings = {
          inherit (config.cardano) network;
          server.debug = true;
          dbSync = {
            inherit (dbsync-cfg.postgres) user port database;
            host = dbsync-cfg.postgres.socketdir; # Required, to force connect by local socket, as well as local auth
          };
        };
      };
      services.postgresql = {
        identMap = ''
          users ${config.services.blockfrost.user} ${config.services.cardano-db-sync.postgres.user}
          users postgres postgres
        '';
        authentication = ''
          local all all ident map=users
        '';
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
        # FIXME: Turn MemoryDenyWriteExecute prevent service from work
        #          MemoryDenyWriteExecute = true;
        RestrictNamespaces = true;
        ProtectHostname = true;
        ProtectKernelTunables = true;
        RestrictRealtime = true;
        # FIXME: Turn SystemCallFilter prevent service from work
        #          SystemCallFilter = ["@system-service" "~@privileged"];
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
    (mkIf (config.cardano.node.enable or false) {
      systemd.services.blockfrost-backend-ryo = {
        after = ["cardano-node-socket.service"];
        requires = ["cardano-node-socket.service"];
      };
    })
    (mkIf (config.cardano.db-sync.enable or false) {
      systemd.services.blockfrost-backend-ryo = {
        after = ["cardano-db-sync.service"];
        requires = ["cardano-db-sync.service"];
      };
    })
  ]);
}
