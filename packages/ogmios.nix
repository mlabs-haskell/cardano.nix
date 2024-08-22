{
  perSystem = {
    system,
    pkgs,
    lib,
    ...
  }: let
    mkUrl = version: system: "https://github.com/CardanoSolutions/ogmios/releases/download/v${version}/ogmios-v${version}-${system}.zip";
    releases = {
      "6.6.0" = {
        "x86_64-linux" = {
          url = mkUrl "6.6.0" "x86_64-linux";
          hash = "sha256-TiPpgQruKRM40i1iUdlDcG+V1ddgt9L/36zP3qqQlDI=";
        };
      };
      "6.5.0" = {
        "x86_64-linux" = {
          url = mkUrl "6.5.0" "x86_64-linux";
          hash = "sha256-C7vwUefYXCXhnfIUt/Kmj3/f4cd3IogAZxaBtDftUOU=";
        };
      };
      "6.4.0" = {
        "x86_64-linux" = {
          url = mkUrl "6.4.0" "x86_64-linux";
          hash = "sha256-yUdHcnf4K28DS+opILENCtE4fn32qhDylxyptarGnJE=";
        };
      };
      "6.3.0" = {
        "x86_64-linux" = {
          url = mkUrl "6.3.0" "x86_64-linux";
          hash = "sha256-sl16WKX1WTNENrt1STbgDjtYiQTx1NmAJ6L4miryA8E=";
        };
      };
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
