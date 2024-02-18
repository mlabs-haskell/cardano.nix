{
  config,
  lib,
  ...
}: let
  cardanoTypes = import ./types.nix {inherit lib;};
  inherit (lib) types mkOption mkEnableOption mkIf recursiveUpdate;
  inherit (types) str listOf;
  inherit (cardanoTypes) shelleyEraKeysType addressPortType generateShelleyKeysOptions;
  cfg = config.cardanoNix.cardano-node.producer;
  inherit (config.cardanoNix.cardano-node) defaults;

  # [{address : str, port : int}] -> topology file derivation
  # mimicks topology.json format
  # Topology where every peer has single access point. TODO: allow to overwrite
  mkBlockProducerTopology = relayAddrs: {
    localRoots =
      map (
        addr: {
          accessPoints = [addr];
          advertise = false;
          valency = 1;
        }
      )
      relayAddrs;
    publicRoots = [
      {
        accessPoints = [
        ];
        advertise = false;
      }
    ];
    useLedgerAfterSlot = -1;
  };
in {
  options = {
    # NOTE: This is user facing option set, keep it simple and strongly typed
    cardanoNix.cardano-node.producer = {
      enable = mkEnableOption "producer";

      relayAddrs = mkOption {
        type = listOf addressPortType;
      };

      name = mkOption {
        type = types.str;
        default = "producer";
      };

      shelleyEraKeys = mkOption {
        type = shelleyEraKeysType;
      };
    };
  };

  config = mkIf cfg.enable {
    cardanoNix.cardano-node.instances.${cfg.name} = recursiveUpdate defaults {
      topology = mkBlockProducerTopology cfg.relayAddrs;
      options =
        {
          # Some local options here
        }
        // generateShelleyKeysOptions cfg.shelleyEraKeys;
    };
  };
}
