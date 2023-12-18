{
  lib,
  config,
  ...
}: let
  cfg = config.cardanoNix.globals;
  inherit (lib) types;
in
  # FIXME: proper assertion, private also can have any unused number
  #  assert cfg.networkNumbers ? cfg.network;
  {
    options.cardanoNix.globals = {
      network = lib.mkOption {
        type = types.enum (builtins.attrNames cfg.networkNumbers);
        default = "mainnet";
        description = ''
          Cardano network to join/use
        '';
      };
      networkNumber = lib.mkOption {
        type = types.int;
        default = cfg.networkNumbers.${cfg.network};
        defaultText = lib.literalExpression "config.cardanoNix.globals.networkNumbers.\${config.cardanoNix.globals.net}";
        description = ''
          Cardano network number to join/use (should match cardanoNix.globals,network)
        '';
        internal = true;
      };
      networkNumbers = lib.mkOption {
        type = types.attrsOf types.int;
        default = {
          mainnet = 0;
          preprod = 1;
          preview = 2;
          sanchonet = 4;
          private = 42;
        };
        description = ''
          Cardano network numbers
        '';
        internal = true;
      };
    };
  }
