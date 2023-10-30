{
  lib,
  config,
  ...
}: let
  cfg = config.cardano-ecosystem.globals;
in
  # FIXME: proper assertion, private also can have any unused number
  #  assert cfg.networkNumbers ? cfg.network;
  with lib; {
    options.cardano-ecosystem.globals = {
      network = mkOption {
        type = types.enum (builtins.attrNames networkNumbers);
        default = "mainnet";
        description = ''
          Cardano network to join/use
        '';
      };
      networkNumber = mkOption {
        type = types.int;
        default = networkNumbers.${cfg.network};
        description = ''
          Cardano network number to join/use (should match cardano-ecosystem.globals,network)
        '';
      };
      networkNumbers = mkOption {
        type = types.attrsOf types.int;
        # FIXME: fill other nets
        # FIXME: could we extract networkNumbers automatically?
        # FIXME: could we extract it from IOG nix stuff w/o IFD or massive inclusion of https://github.com/input-output-hk/iohk-nix
        default = {
          mainnet = 0;
          preprod = 1;
          preview = 2;
          sanchonet = 4;
          private = 42;
        };
        internal = true;
      };
    };
  }
