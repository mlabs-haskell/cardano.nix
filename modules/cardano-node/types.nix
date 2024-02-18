{lib}: let
  inherit (lib) types optionalAttrs mkOption;
  inherit (types) submodule either path str int bool listOf nullOr attrsOf anything;
in rec {
  addressPortType = submodule {
    options = {
      address = mkOption {
        type = str;
      };
      port = mkOption {
        type = int;
      };
    };
  };
  rootsType = isLocal:
    submodule {
      options =
        {
          accessPoints = mkOption {
            type = listOf addressPortType;
            default = [];
          };
          advertise = mkOption {
            type = bool;
            default = false;
          };
        }
        // optionalAttrs isLocal {
          valency = mkOption {
            type = int;
            default = 1;
          };
        };
    };
  topologyType = submodule {
    options = {
      localRoots = mkOption {
        type = listOf (rootsType true);
        default = [];
      };
      publicRoots = mkOption {
        type = listOf (rootsType false);
        default = [];
      };
      useLedgerAfterSlot = mkOption {
        type = int;
        default = -1;
      };
    };
  };

  # FIXME: do we want fully-typed schema for config here?
  nodeConfigType = attrsOf anything;

  # FIXME: do we need support older eras key?
  shelleyEraKeysType = submodule {
    options = {
      # Shelly+ era secrets path definitions
      vrfKey = mkOption {
        #        "${name}-vrf.skey";
        type = either path str;
      };
      kesKey = mkOption {
        type = either path str;
        # "${name}-kes.skey";
      };
      #      coldVerification = mkOption {
      #        type = either path str;
      #        # "${name}-cold.vkey";
      #      };
      operationalCertificate = mkOption {
        type = either path str;
        # "${name}.opcert";
      };
      bulkCredentials = mkOption {
        type = nullOr (either path str);
        default = null;
        # "${name}-bulk.creds";
      };
    };
  };

  # FIXME: check all options names for node, attrNames here should match node argument name
  generateShelleyKeysOptions = keys:
    {
      "shelley-kes-key" = keys.kesKey;
      "shelley-vrf-key" = keys.vrfKey;
      "shelley-operational-certificate" = keys.operationalCertificate;
    }
    // optionalAttrs (keys.bulkCredentials != null) {"bulk-credentials-file" = keys.bulkCredentials;};
}
