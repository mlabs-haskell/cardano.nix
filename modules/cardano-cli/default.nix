{
  config,
  self',
  lib,
  ...
}: {
  options.cardanoNix.cardano-cli.enable = lib.mkEnableOption "Install cardano CLI tools and scripts";

  config = lib.mkIf config.cardanoNix.cardano-cli.enable {
    environment.systemPackages = [
      self'.packages.cardano-cli
    ];
  };
}
