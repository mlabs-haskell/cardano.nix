{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.cardano-ecosystem.cli.enable = mkEnableOption "Install cardano CLI tools and scripts";

  config = mkIf config.cardano-ecosystem.cli.enable {
    environment.systemPackages = with pkgs; [
      git # FIXME: just a placeholder
    ];
  };
}
