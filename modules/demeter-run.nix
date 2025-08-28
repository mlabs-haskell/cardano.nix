{ config, lib, ... }:

let
  cfg = config.cardano.demeter-run;
  dmtr_cfg = config.services.demeter-run;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.cardano.demeter-run = {
    node = {
      enable = mkEnableOption "Demeter run tunnel";
      instance = mkOption {
        type = types.str;
      };

      configFile = mkOption {
        type = types.str;
        description = ''
          Config file for demeter setup (contain secrets, use agenix or sops)
        '';
      };
    };

    # FIXME: not implemented yet
    kupo = { };

    # FIXME: not implemented yet
    ogmios = { };
  };

  config = mkIf cfg.node.enable {
    services.demeter-run = {
      enable = true;
      inherit (cfg.node) instance;
      inherit (cfg.node) configFile;
    };

    # Register as cardano-node socket provider
    cardano.providers.node = {
      socketPath = dmtr_cfg.socket;
      accessGroup = dmtr_cfg.group;
      requires = "demeter-run.service";
      after = "demeter-run.service";
    };
  };
}
