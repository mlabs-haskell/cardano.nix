# NOTE: This module provide streamlined and semi-typed unified interface to operate cardano-node instances
# It intended for use internally by .relay and .producer modules, as well as useful for develop tests.
# It not intended to end-users.
{
  config,
  lib,
  pkgs,
  cardanoNixInternals,
  ...
}: let
  cardanoTypes = import ./types.nix {inherit lib;};
  inherit (cardanoNixInternals) inputs;
  inherit (builtins) length attrNames map toFile toJSON;
  inherit (lib) concatStringsSep types mkOption mapAttrs' nameValuePair flip getExe mkIf optional recursiveUpdate;
  inherit (types) submodule listOf attrsOf package str either path bool nullOr;
  inherit (cardanoTypes) topologyType nodeConfigType addressPortType;
  cfg = config.cardanoNix.cardano-node;
  inherit (config.cardanoNix) packages;
  cardano-lib = pkgs.callPackage "${inputs.iohk-nix}/cardano-lib" {};

  inherit (cardano-lib) environments;
  mkConfig = instance: let
    basicConfig = environments.${instance.environment}.nodeConfig;
  in
    toFile "cardano-node-config.json" (toJSON (recursiveUpdate basicConfig instance.nodeConfig));
  mkTopologyFile = instance:
    toFile "topology.json" (toJSON instance.topology);

  # FIXME: move all types to `types.nix`?
  # Options shared between "cardanoNix.cardano-node.defaults" "and cardanoNix.cardano-node.instance.$name"
  processOptions = submodule ({config, ...}: {
    options = {
      name = mkOption {
        type = str;
        internal = true;
        default = config._module.args.name;
        description = ''
          For instances, should match attr name in `cardano-node.instances`
        '';
      };

      package = mkOption {
        type = package;
        default = packages.cardano-node;
      };

      options = mkOption {
        type = attrsOf str;
        description = ''
          Key-value pairs, auto-convertable to command-line arguments --arg value
          (Semi-internal)
        '';
        default = {};
      };

      extraCommandLineArgs = mkOption {
        type = listOf str;
        default = [];
      };

      extraSystemdOptions = mkOption {
        type = types.lazyAttrsOf types.any;
        default = {};
      };

      environment = mkOption {
        type = types.enum (attrNames environments);
        default = "preprod";
        description = ''
          environment node will connect to
        '';
      };

      stateDirectory = mkOption {
        type = nullOr str;
        description = ''
        '';
        default = "cardano-node";
      };

      dbPath = mkOption {
        type = str;
        description = ''
          path for DB files
        '';
        default = "/var/lib/cardano-node"; # FIXME: ensure that is unique per-instance
      };

      socketPath = mkOption {
        type = str;
        description = ''
          Path to cardano-nix socket
        '';
        default = "/run/cardano-node/node.socket"; # FIXME: ensure that is unique per-instance
      };

      runtimeDirectory = mkOption {
        type = str;
        description = ''
          Runtime path for sockets, etc (relative to /run).
        '';
        default = "cardano-node";
      };

      useSnapshot = mkOption {
        type = bool;
        description = ''
          use snapshot
        '';
        # FIXME: need at least a stub `config.cardanoNix.cardano-snapshot-download` to uncomment
        # default = config.cardanoNix.cardano-snapshot-download.enable;
        default = false;
      };

      listen = mkOption {
        type = addressPortType;
        default = {
          # FIXME: Shoundn't have default, and must set explicitly in downstream modules
          address = "127.0.0.1";
          port = 3001;
        };
      };

      topologyFile = mkOption {
        type = nullOr (either str path);
        internal = true;
        defaultText = lib.literalExpression ''
          # default implementation (for reference purpose)
          topologyFile = mkTopologyFile instance.topology;
        '';
        default = null; # if not set, serialized instance.topology used
      };
      topology = mkOption {
        type = topologyType;
        default = {};
      };
      nodeConfigFile = mkOption {
        type = nullOr (either path str);
        internal = true;
        default = null;
      };
      nodeConfig = mkOption {
        type = nodeConfigType;
        default = {};
      };
    };
  });
in {
  options.cardanoNix.cardano-node = {
    defaults = mkOption {
      type = processOptions;
      description = ''
        Set of instance defaults
      '';
      default = {};
    };
    instances = mkOption {
      type = types.attrsOf processOptions;
      description = ''
        internally populated set of node instances relay, node, edge, or some custom modules can populate it.
        As side effect, it allow to host all type of node on single host, althougt it NOT recommended for mainnet deployment.
      '';
      internal = true;
      default = {};
    };
  };

  config = mkIf (length (attrNames cfg.instances) > 0) {
    systemd.services =
      {
        # default systemd service to control them all (FIXME: now a stub)
        # FIXME: just rename "cardano-node-${instance.name}" to cardano-node in case of single node?
        cardano-node = {
          description = "Control all instances at once.";
          enable = true;
          wants = map (name: "cardano-node-${name}.service") (attrNames cfg.instances);
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = "yes";
            User = "cardano-node";
            Group = "cardano-node";
            ExecStart = "${pkgs.coreutils}/bin/echo 'Starting cardano-node instances: ${concatStringsSep ", " (attrNames cfg.instances)}.'";
            WorkingDirectory = "/var/lib/cardano-node";
            StateDirectory = "cardano-node";
          };
        };
      }
      // flip mapAttrs' cfg.instances (name: instance: let
        configFile =
          if instance.nodeConfigFile != null
          then instance.nodeConfigFile
          else mkConfig instance;
        topologyFile =
          if instance.topologyFile != null
          then instance.topologyFile
          else mkTopologyFile instance;
        options =
          {
            "config" = configFile;
            "topology" = topologyFile;
            "database-path" = instance.dbPath;
            "socket-path" = instance.socketPath;
            "host-addr" = instance.listen.address;
            "port" = instance.listen.port;
          }
          // instance.options;
        nodeArguments = (lib.cli.toGNUCommandLine {} options) ++ instance.extraCommandLineArgs;
      in
        nameValuePair "cardano-node-${name}" {
          enable = true;
          description = "Cardano node instance for ${instance.name}";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          requires = optional instance.useSnapshot "cardano-node-${instance.name}-snapshot.service"; # One shot, which should depends on downloader
          serviceConfig = {
            inherit (instance) runtimeDirectory stateDirectory;
            User = "cardano-node";
            Group = "cardano-node";
            #            WorkingDirectory = "/var/lib/cardano-node";
          };
          script = ''
            # Show commandline before execution
            set -x
            exec ${getExe instance.package} run ${lib.concatStringsSep " " nodeArguments}
          '';
        });
    systemd.tmpfiles.rules =
      flip lib.mapAttrsToList cfg.instances (_name: instance: "d /var/lib/${instance.stateDirectory} 0700 cardano-node cardano-node -")
      ++ flip lib.mapAttrsToList cfg.instances (_name: instance: "d /run/${instance.runtimeDirectory} 0700 cardano-node cardano-node -");
    ## Code below is same as `systemd.tmpfiles.rules` above, but wait for pending change from unstable
    #      systemd.tmpfiles.settings = flip mapAttrs' cfg.instances (name: instance:
    #        nameValuePair name (
    #          nameValuePair "/var/lib/${instance.stateDirectory}" {
    #            mode = "0700";
    #            user = "cardano-node";
    #            group = "cardano-node";
    #          }
    #        ));
  };
}
