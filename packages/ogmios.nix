{
  perSystem = {
    system,
    pkgs,
    lib,
    ...
  }: let
    mkUrl = version: system: "https://github.com/CardanoSolutions/ogmios/releases/download/v${version}/ogmios-v${version}-${system}.zip";
    releases = {
      "6.2.0" = {
        "x86_64-linux" = {
          url = mkUrl "6.2.0" "x86_64-linux";
          hash = "sha256-FxYJLAVLhW/YYmaTSkBCWung/BjAqvPotUXWHvo+Aqs=";
        };
      };
      "6.1.0" = {
        "x86_64-linux" = {
          url = mkUrl "6.1.0" "x86_64-linux";
          hash = "sha256-8Qj9/EZo4t5o8BN/ystkTTfvoqtUIYY9GJYACX+bTUY=";
        };
      };
      "6.0.3" = {
        "x86_64-linux" = {
          url = mkUrl "6.0.3" "x86_64-linux";
          hash = "sha256-Gn6c17Dfyb4M4ec/94LFJSS1y0S0wS8KciEz9s7uIEw=";
        };
      };
    };
    mkPackage = version:
      pkgs.fetchzip {
        inherit (releases.${version}.${system}) url hash;
        stripRoot = false;
        name = "ogmios-${version}";
        postFetch = "chmod +x $out/bin/ogmios";
      }
      // {inherit version;};
  in {
    packages =
      lib.mapAttrs' (v: _: {
        name = "ogmios-${v}";
        value = mkPackage v;
      })
      releases;
  };
}
