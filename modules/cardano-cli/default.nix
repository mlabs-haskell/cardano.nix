{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.cardanoNix.cardano-cli.enable = mkEnableOption "Install cardano CLI tools and scripts";

  config = mkIf config.cardanoNix.cardano-cli.enable {
    environment.systemPackages = with pkgs; [
      git # FIXME: just a placeholder
    ];
  };
}
