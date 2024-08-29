{
  lib,
  config,
  ...
}: let
  cfg = config.cardano;
  inherit (lib) types;
in {
  options.cardano = {
    enable = lib.mkEnableOption "all Cardano services and HTTP proxy";
    network = lib.mkOption {
      description = "Cardano network to operate on.";
      type = types.enum (lib.attrNames cfg.networkNumbers);
      default = "mainnet";
    };
    networkNumber = lib.mkOption {
      description = "Cardano network number to operate on. Defaults to the network number of the selected network.";
      internal = true;
      type = types.int;
      default = cfg.networkNumbers.${cfg.network};
      defaultText = lib.literalExpression "config.cardano.networkNumbers.\${config.cardano.network}";
    };
    networkNumbers = lib.mkOption {
      description = "Map from network names to network numbers. Selected network must be present in the map";
      type = types.attrsOf types.int;
      default = {
        mainnet = 764824073;
        preprod = 1;
        preview = 2;
        sanchonet = 4;
        private = 42;
      };
      internal = true;
    };
  };
}
