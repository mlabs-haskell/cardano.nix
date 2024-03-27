{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cardanoNix.cardano-cli.enable = lib.mkEnableOption "cardano-cli in systemPackages";

  config = lib.mkIf config.cardanoNix.cardano-cli.enable {
    environment.systemPackages = [
      pkgs.cardano-cli
    ];
  };
}
