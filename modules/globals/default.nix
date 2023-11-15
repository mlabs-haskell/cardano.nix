{
  lib,
  config,
  ...
}: let
  cfg = config.cardanoNix.globals;
in
  # FIXME: proper assertion, private also can have any unused number
  #  assert cfg.networkNumbers ? cfg.network;
  with lib; {
    options.cardanoNix.globals = {
      network = mkOption {
        type = types.enum (builtins.attrNames cfg.networkNumbers);
        default = "mainnet";
        description = ''
          Cardano network to join/use
        '';
      };
      networkNumber = mkOption {
        type = types.int;
        default = cfg.networkNumbers.${cfg.network};
        description = ''
          Cardano network number to join/use (should match cardanoNix.globals,network)
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
