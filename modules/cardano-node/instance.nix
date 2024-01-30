{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) length attrNames;
  inherit (lib) types mkOption mapAttrs mapAttrs' nameValuePair flip getBin toGNUCommandLineShell mkIf optional;
  inherit (types) submodule;
  cfg = config.cardanoNix.cardano-node;

  # Options shared between "cardanoNix.cardano-node.defaults" "and cardanoNix.cardano-node.instance.$name"
  processOptions = {
    package = {
      type = types.package;
    };

    options = {
      type = types.attrsOf types.str; #FIXME properly typed option for arguments node executable
    };
    dbPath = {
      type = types.str;
      description = ''
        path for DB files
      '';
    };
    useSnapshot = {
      type = types.str;
      description = ''
        use snapshot
      '';
      # FIXME: need at least a stub `config.cardanoNix.cardano-snapshot-download` to uncomment
      # default = config.cardanoNix.cardano-snapshot-download.enable; 
      default = false;
    };
    topologyFile = {
      type = types.str;
      internal = true;
      # default = mkTopologyFile po.topology;
    };
    #    topology = {
    #      type = submodule
    #    };
  };

  defaults = {
    package = pkgs.cardano-node;
    options = {};
    extraOptions = [];
  };

  # Here we construct two submodules -- one for defaultProcessOption with defaults, second one for `instances` which should be defaulted to .defaults
  # Partially a trick

  # Enhance with defaults
  defaultProcessOptions = submodule (mapAttrs (name: option: mkOption option // {default = defaults.${name};}) processOptions);

  # Enhance with reference to config.cardanoNix.cardano-node.default
  instanceProcessOptions = submodule (mapAttrs (name: option: mkOption option // {default = config.cardanoNix.cardano-node.defaults.${name};}) processOptions);
in {
  options.cardanoNix.cardano-node = {
    defaults = defaultProcessOptions;
    instances = mkOption {
      type = types.attrsOfSubmodule instanceProcessOptions;
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
          required = optional "cardano-node-${instance.name}-snapshot.service"; # One shot, which should depends on downloader
          script = ''
            exec ${getBin instance.package}/bin/cardano-node run ${toGNUCommandLineShell instance.options}
          '';
        });
  };
}
