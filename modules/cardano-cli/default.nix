{self, ...}: {
  flake.nixosModules.cardano-cli = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) system;
  in {
    options.cardanoNix.cardano-cli.enable = lib.mkEnableOption "Install cardano CLI tools and scripts";

    config = lib.mkIf config.cardanoNix.cardano-cli.enable {
      environment.systemPackages = [
        self.packages.${system}.cardano-cli
      ];
    };
  };
}
