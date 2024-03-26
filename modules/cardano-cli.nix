{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cardano.cli.enable = lib.mkEnableOption "cardano-cli in systemPackages";

  config = {
    cardano.cli.enable = lib.mkOptionDefault (config.cardano.node.enable or false);
    environment.systemPackages = lib.mkIf config.cardano.cli.enable [
      pkgs.cardano-cli
    ];
  };
}
