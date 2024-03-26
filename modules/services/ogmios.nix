# NixOS module for configuring Ogmios service.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.ogmios;
in {
  options.services.ogmios = with types; {
    enable = mkEnableOption "Ogmios bridge interface for cardano-node";

    package = mkOption {
      description = "Ogmios package";
      type = package;
      default = pkgs.ogmios;
    };

    user = mkOption {
      description = "User to run Ogmios service as.";
      type = str;
      default = "ogmios";
    };

    group = mkOption {
      description = "Group to run Ogmios service as.";
      type = str;
      default = "ogmios";
    };

    nodeSocketPath = mkOption {
      description = "Path to cardano-node IPC socket.";
      type = path;
      default = "/run/cardano-node/node.socket";
    };

    nodeConfigPath = mkOption {
      description = "Path to cardano-node config.json file. Required.";
      type = path;
    };

    host = mkOption {
      description = "Host address or name to listen on.";
      type = str;
      default = "localhost";
    };

    port = mkOption {
      description = "TCP port to listen on.";
      type = port;
      default = 1337;
    };

    extraArgs = mkOption {
      description = "Extra arguments to ogmios command.";
      type = listOf str;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    users.users.ogmios = mkIf (cfg.user == "ogmios") {
      isSystemUser = true;
      inherit (cfg) group;
      extraGroups = ["cardano-node"];
    };
    users.groups.ogmios = mkIf (cfg.group == "ogmios") {};

    systemd.services.ogmios = {
      enable = true;
      after = ["cardano-node.service"];
      wantedBy = ["multi-user.target"];

      script = escapeShellArgs (concatLists [
        ["${cfg.package}/bin/ogmios"]
        ["--node-socket" cfg.nodeSocketPath]
        ["--node-config" cfg.nodeConfigPath]
        ["--host" cfg.host]
        ["--port" cfg.port]
        cfg.extraArgs
      ]);

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        # Security
        UMask = "0077";
        CapabilityBoundingSet = "";
        ProcSubset = "pid";
        ProtectProc = "invisible";
        NoNewPrivileges = true;
        DevicePolicy = "closed";
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        PrivateMounts = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = ["@system-service" "~@privileged"];
        MemoryDenyWriteExecute = true;
      };
    };
  };
}
