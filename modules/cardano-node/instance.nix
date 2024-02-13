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
  inherit (builtins) length attrNames;
  inherit (lib) types mkOption mapAttrs' nameValuePair flip getBin toGNUCommandLineShell mkIf optional;
  inherit (types) submodule;
  inherit (cardanoTypes) topologyType;
  cfg = config.cardanoNix.cardano-node;

  # FIXME: move all types to `types.nix`?
  # Options shared between "cardanoNix.cardano-node.defaults" "and cardanoNix.cardano-node.instance.$name"
  processOptions'.options = {
    package = mkOption {
      type = types.package;
      package = pkgs.cardano-node; # FIXME: would we want to
    };

    options = mkOption {
      type = types.attrsOf types.str;
      description = ''
        Key-value pairs, auto-convertable to command-line arguments --arg value
        (Semi-internal)
      '';
    };

    extraCommandLine = mkOption {
      type = types.lines;
      default = [];
    };

    extraSystemdOptions = mkOption {
      type = types.lazyAttrsOf types.any;
      default = {};
    };

    dbPath = mkOption {
      type = types.str;
      description = ''
        path for DB files
      '';
    };
    useSnapshot = mkOption {
      type = types.str;
      description = ''
        use snapshot
      '';
      # FIXME: need at least a stub `config.cardanoNix.cardano-snapshot-download` to uncomment
      # default = config.cardanoNix.cardano-snapshot-download.enable;
      default = false;
    };
    topologyFile = mkOption {
      type = types.either types.str types.path;
      internal = true;
      literalExample = ''
        # default implementation (for reference purpose)
        topologyFile = mkTopologyFile instance.topology;
      '';
    };
    topology = {
      type = topologyType;
    };
  };

  # FIXME: kludge in case if we want to extend instance with exclusive options
  processOptions = submodule processOptions';
in {
  options.cardanoNix.cardano-node = {
    defaults = mkOption {
      type = processOptions;
      description = ''
        Set of instance defaults
      '';
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
    # Dummy implementation now
    systemd.services =
      {
        # default systemd service to control them all (FIXME: now a stub)
        # FIXME: just rename "cardano-node-${instance.name}" to cardano-node in case of single node?
        cardano-node = {};
      }
      // flip mapAttrs' cfg.instances (name: instance:
        nameValuePair "cardano-node-${instance.name}" {
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          required = optional instance.useSnapshot "cardano-node-${instance.name}-snapshot.service"; # One shot, which should depends on downloader
          script = ''
            # Show commandline before execution
            set -x
            exec ${getBin instance.package}/bin/cardano-node run ${toGNUCommandLineShell instance.options}
          '';
        });
  };
}
