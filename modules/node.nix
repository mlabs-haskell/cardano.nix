{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cardano.node;
  inherit (builtins) elemAt match replaceStrings readFile;
in {
  options.cardano.node = {
    enable =
      lib.mkEnableOption "cardano-node service"
      // {default = config.cardano.enable or false;};

    socketPath = lib.mkOption {
      description = "Path to cardano-node socket.";
      type = lib.types.path;
      default = "/run/cardano-node/node.socket";
    };

    configPath = lib.mkOption {
      description = "Path to cardano-node configuration.";
      type = lib.types.path;
      default = "/etc/cardano-node/config.json";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."cardano-node/config.json" = {
      # hack to get config file path
      text = readFile (elemAt (match ".* --config ([^ ]+) .*" (replaceStrings ["\n"] [" "] config.services.cardano-node.script)) 0);
      user = "cardano-node";
      group = "cardano-node";
    };

    environment.variables = {
      CARDANO_NODE_SOCKET_PATH = cfg.socketPath;
    };

    services.cardano-node = {
      enable = true;

      package = lib.mkDefault pkgs.cardano-node;
      inherit (cfg) socketPath;
      environment = config.cardano.network;

      # Listen on all interfaces.
      hostAddr = lib.mkDefault "0.0.0.0";

      # Reload unit if p2p and only topology changed.
      useSystemdReload = true;
    };

    # Workaround: cardano-node service does not support systemdSocketActivation with p2p topology.
    # Socket created by cardano-node is not writable by group . So we wait until it appears and set the permissions.
    systemd.services.cardano-node-socket = {
      description = "Wait for cardano-node socket to appear and set permissions to allow group read and write.";
      after = ["cardano-node.service"];
      requires = ["cardano-node.service"];
      bindsTo = ["cardano-node.service"];
      requiredBy = ["cardano-node.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      # Using a path unit doesn't allow dependencies to be declared correctly, so poll.
      script = ''
        echo 'Waiting for ${cfg.socketPath} to appear...'
        /bin/sh -c 'until test -e ${cfg.socketPath}; do sleep 1; done'
        echo 'Changing permissions for ${cfg.socketPath}.'
        chmod g+rw ${cfg.socketPath}
      '';
    };
  };
}
