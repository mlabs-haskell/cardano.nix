{self, ...}: {
  flake.nixosModules.packages = {
    pkgs,
    lib,
  }: let
    inherit (lib) types mkOption docMD;
    inherit (types) path;
    inherit (pkgs.stdenv.hostPlatform) system;
  in {
    options.cardanoNix.packages = {
      cardano-node = mkOption {
        type = path;
        description = docMD ''
          Default package for cardano-node
        '';
      };
      cardano-cli = mkOption {
        type = path;
        description = docMD ''
          Default package for cardano-cli
        '';
      };
    };
    config.packages = {
      inherit (self.packages.${system}) cardano-node cardano-cli;
    };
  };
}
