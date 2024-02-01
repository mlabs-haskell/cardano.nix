{lib}: let
  inherit (lib) types optionalAttrs;
  inherit (types) mkOption submodule nullOr either path str;
in {
  topologyType =
    submodule {
    };

  # FIXME: do we need support older eras key?
  shellyEraKeysType = submodule {
    # Shelly+ era secrets path definitions
    vrfKey = mkOption {
      #        "${name}-vrf.skey";
      type = either path str;
    };
    kesKey = mkOption {
      type = either path str;
      # "${name}-kes.skey";
    };
    coldVerification = mkOption {
      type = either path str;
      # "${name}-cold.vkey";
    };
    operationalCertificate = mkOption {
      type = either path str;
      # "${name}.opcert";
    };
    bulkCredentials = mkOption {
      type = nullOr (either path str);
      # "${name}-bulk.creds";
    };
  };

  # FIXME: check all options names for node, attrNames here should match node argument name
  generateShelleyKeysOptions = keys:
    {
      "kes-key" = keys.kesKey;
      "vrf-key" = keys.vrfKey;
      "cold-verification" = keys.coldVerification;
    }
    // optionalAttrs keys.bulkCredentials {"bulk-credentials-file" = keys.bulkCredentials;};
}
