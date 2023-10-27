{
  perSystem = {pkgs, ...}: {
    devshells.default = {
      name = "cardano.nix";
      packages = with pkgs; [
        statix
        config.treefmt.build.wrapper
      ];
    };
  };
}
