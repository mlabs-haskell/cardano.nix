{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cardanoNix.cardano-cli.enable = lib.mkEnableOption "Install cardano CLI tools and scripts";

  config = lib.mkIf config.cardanoNix.cardano-cli.enable {
    environment.systemPackages = [
      pkgs.git # TODO: replace with `cardano-cli` (milestone 2)
    ];
  };
}
