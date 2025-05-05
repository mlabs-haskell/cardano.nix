{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cardano.node;
  inherit (builtins)
    elemAt
    match
    replaceStrings
    readFile
    ;
in
{
  options.cardano.node = {
    enable = lib.mkEnableOption "cardano-node service";

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

    copyCardanoNodeConfigToEtc = lib.mkOption {
      description = "If set to true, this will -- at Nix evaluation time -- copy the cardano node's config file to `/etc/cardano-node/config.json`";
      type = lib.types.bool;
      default = true;
    };

    prometheusExporter.enable = lib.mkEnableOption "prometheus exporter";

    prometheusExporter.port = lib.mkOption {
      description = "Port where Prometheus exporter is exposed.";
      type = lib.types.port;
      default = 12798;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = lib.mkIf cfg.copyCardanoNodeConfigToEtc {
      "cardano-node/config.json" = {
        # NOTE(jaredponn): This is a hack to get config file path
        # This line forces the config file to be known at Nix
        # evaluation time which causes trouble if you want to
        # "dynamically create" the config which is desirable when --
        # for example -- creating a test node setup that sets the
        # system start time to now.

        text = readFile (elemAt (match ".* --config ([^ ]+) .*" (replaceStrings [ "\n" ] [ " " ] config.services.cardano-node.script)) 0);
        user = "cardano-node";
        group = "cardano-node";
      };
    };

    environment.variables = {
      # Set convenience environment variables when interacting with the node
      # via `cardano-cli` in the machine.
      # In particular, see
      # https://github.com/IntersectMBO/cardano-cli/blob/master/cardano-cli/src/Cardano/CLI/Environment.hs
      # for details on the environment variables it reads.
      CARDANO_NODE_SOCKET_PATH = cfg.socketPath;
      CARDANO_NODE_NETWORK_ID = if config.cardano.network == "mainnet" then "mainnet" else config.cardano.networkNumber;
    };

    services.cardano-node = {
      enable = true;

      package = lib.mkDefault pkgs.cardano-node;
      inherit (cfg) socketPath;
      environment = config.cardano.network;

      extraNodeConfig = lib.mkIf cfg.prometheusExporter.enable {
        hasPrometheus = [
          "0.0.0.0"
          config.cardano.node.prometheusExporter.port
        ];
      };

      # Listen on all interfaces.
      hostAddr = lib.mkDefault "0.0.0.0";

      # Reload unit if p2p and only topology changed.
      useSystemdReload = true;
    };

    # Workaround: cardano-node service does not support systemdSocketActivation with p2p topology.
    # Socket created by cardano-node is not writable by group . So we wait until it appears and set the permissions.
    systemd.services.cardano-node-socket = {
      description = "Wait for cardano-node socket to appear and set permissions to allow group read and write.";
      after = [ "cardano-node.service" ];
      requires = [ "cardano-node.service" ];
      bindsTo = [ "cardano-node.service" ];
      requiredBy = [ "cardano-node.service" ];
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
