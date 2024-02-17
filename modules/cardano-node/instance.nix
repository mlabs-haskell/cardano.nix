# NOTE: This module provide streamlined and semi-typed unified interface to operate cardano-node instances
# It intended for use internally by .relay and .producer modules, as well as useful for develop tests.
# It not intended to end-users.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cardanoTypes = import ./types.nix {inherit lib;};
  inherit (builtins) length attrNames map;
  inherit (lib) types mkOption mapAttrs' nameValuePair flip getExe mkIf optional;
  inherit (types) submodule listOf attrsOf package str either path bool;
  inherit (cardanoTypes) topologyType;
  cfg = config.cardanoNix.cardano-node;

  # FIXME: move all types to `types.nix`?
  # Options shared between "cardanoNix.cardano-node.defaults" "and cardanoNix.cardano-node.instance.$name"
  processOptions = submodule ({config, ...}: {
    options = {
      name = mkOption {
        type = str;
        internal = true;
        default = config._module.arg.name;
        description = ''
          For instances, should match attr name in `cardano-node.instances`
        '';
      };

      package = mkOption {
        type = package;
        default = config.cardanoNix.packages.cardano-node;
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

      dbPath = mkOption {
        type = str;
        description = ''
          path for DB files
        '';
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
      topologyFile = mkOption {
        type = either str path;
        internal = true;
        defaultText = lib.literalExpression ''
          # default implementation (for reference purpose)
          topologyFile = mkTopologyFile instance.topology;
        '';
      };
      topology = mkOption {
        type = topologyType;
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
            ExecStart = "${pkgs.coreutils}/bin/echo 'Starting cardano-node instances'";
            WorkingDirectory = "/var/lib/cardano-node";
            StateDirectory = "cardano-node";
          };
        };
      }
      // flip mapAttrs' cfg.instances (name: instance: let
        nodeArguments = (lib.cli.toGNUCommandLine {} instance.options) ++ instance.extraCommandLineArgs;
      in
        nameValuePair "cardano-node-${name}" {
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          requires = optional instance.useSnapshot "cardano-node-${instance.name}-snapshot.service"; # One shot, which should depends on downloader
          script = ''
            # Show commandline before execution
            set -x
            exec ${getExe instance.package} run ${lib.concatStringsSep " " nodeArguments}
          '';
        });
  };
}
