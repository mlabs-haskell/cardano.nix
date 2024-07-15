{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.kupo;
  inherit (lib) escapeShellArgs flatten types mkOption mkEnableOption mkIf optional;
in {
  options.services.kupo = {
    enable = mkEnableOption "Kupo Cardano chain-indexer";

    package = mkOption {
      description = "Kupo package.";
      type = types.package;
      default = pkgs.kupo or null;
    };

    user = mkOption {
      description = "User to run kupo service as.";
      type = types.nonEmptyStr;
      default = "kupo";
    };

    group = mkOption {
      description = "Group to run kupo service as.";
      type = types.nonEmptyStr;
      default = "kupo";
    };

    workDir = mkOption {
      description = "Directory to start the kupo and store its data. Must start with `/var/lib/`.";
      type = types.path;
      default = "/var/lib/kupo";
    };

    host = mkOption {
      description = "Host address or name to listen on.";
      type = types.nonEmptyStr;
      default = "127.0.0.1";
    };

    port = mkOption {
      description = "TCP port to listen on.";
      type = types.port;
      default = 1442;
    };

    nodeSocketPath = mkOption {
      description = "Path to cardano-node IPC socket. Ignored if `ogmiosHost` is not `null`.";
      type = types.nullOr types.path;
      default = "/run/cardano-node/node.socket";
    };

    nodeConfigPath = mkOption {
      description = "Path to cardano-node config.json file. Ignored if `ogmiosHost` is not `null`";
      type = types.path;
      default = "/etc/cardano-node/config.json";
    };

    ogmiosHost = mkOption {
      description = "Ogmios host name. Optional, will connect to cardano-node if `null`.";
      type = types.nullOr types.nonEmptyStr;
      default = null;
    };

    ogmiosPort = mkOption {
      description = "Ogmios port. Ignored if `ogmiosHost` is `null`.";
      type = types.port;
      default = 1337;
    };

    hydraHost = mkOption {
      description = "Hydra host name. Optional.";
      type = types.nullOr types.nonEmptyStr;
      default = null;
    };

    hydraPort = mkOption {
      description = "Hydra port. Ignored if `hydraHost` is `null`.";
      type = types.port;
    };

    matches = mkOption {
      description = "The list of addresses to watch.";
      type = types.listOf types.nonEmptyStr;
      default = ["*"];
    };

    since = mkOption {
      description = "Watching depth.";
      type = types.nonEmptyStr;
      default = "origin";
    };

    pruneUtxo = mkOption {
      description = "Automatically remove inputs that are spent on-chain.";
      type = types.bool;
      default = false;
    };

    extraArgs = mkOption {
      description = "Extra arguments to kupo command.";
      type = types.listOf types.str;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/var/lib/" cfg.workDir;
        message = "`workDir` must start with `/var/lib/`";
      }
    ];

    users.users.kupo = mkIf (cfg.user == "kupo") {
      isSystemUser = true;
      inherit (cfg) group;
      extraGroups = ["cardano-node"];
    };
    users.groups.kupo = mkIf (cfg.group == "kupo") {};

    systemd.services.kupo = {
      enable = true;
      after = ["cardano-node.service" "ogmios.service"];
      wantedBy = ["multi-user.target"];

      script = escapeShellArgs (flatten [
        ["${cfg.package}/bin/kupo"]
        ["--workdir" cfg.workDir]
        ["--host" cfg.host]
        ["--port" cfg.port]
        (optional (cfg.ogmiosHost == null) [
          ["--node-socket" cfg.nodeSocketPath]
          ["--node-config" cfg.nodeConfigPath]
        ])
        (optional (cfg.ogmiosHost != null) [
          ["--ogmios-host" cfg.ogmiosHost]
          ["--ogmios-port" cfg.ogmiosPort]
        ])
        (optional (cfg.hydraHost != null) [
          ["--hydra-host" cfg.hydraHost]
          ["--hydra-port" cfg.hydraPort]
        ])
        ["--since" cfg.since]
        (map (m: ["--match" m]) cfg.matches)
        (optional cfg.pruneUtxo "--prune-utxo")
        cfg.extraArgs
      ]);

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.workDir;
        StateDirectory = lib.removePrefix "/var/lib/" cfg.workDir;
        # Security
        UMask = "0077";
        AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
        CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = ["~@cpu-emulation @debug @keyring @mount @obsolete @privileged @setuid"];
      };
    };
  };
}
