{
  perSystem = {pkgs, ...}: {
    devshells.default = {
      name = "cardano.nix";
      packages = with pkgs; [
        nix-update
        statix
        mkdocs
        pkgs.python310Packages.mkdocs-material
      ];
    };
  };
}
