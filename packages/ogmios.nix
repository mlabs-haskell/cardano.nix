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
        "x86_64-linux" = pkgs.fetchurl {
          url = mkUrl "6.2.0" "x86_64-linux";
          hash = "sha256-Ryfuzu7JzbR7ivh2Sl9xyOuWh4btjCVSPhXfDLmepHk=";
        };
      };
      "6.1.0" = {
        "x86_64-linux" = pkgs.fetchurl {
          url = mkUrl "6.1.0" "x86_64-linux";
          hash = "sha256-JQJTaws+gihwHpTBtUqcNhgbhFDUAdiiXrO2kMX4ZkY=";
        };
      };
      "6.0.0" = {
        "x86_64-linux" = pkgs.fetchurl {
          url = mkUrl "6.0.0" "x86_64-linux";
          hash = "sha256-BuURF5hgIdmeULeKH2jrCj2Tytnx5Cl9X2Ghx1q4INI=";
        };
      };
    };
    mkPackage = version:
      pkgs.runCommandNoCC "ogmios-${version}" {inherit version;} ''
        mkdir $out
        cd $out
        ${pkgs.unzip}/bin/unzip ${releases.${version}.${system}}
        chmod a+x $out/bin/ogmios
      '';
  in {
    packages =
      lib.mapAttrs' (v: _: {
        name = "ogmios-${v}";
        value = mkPackage v;
      })
      releases;
  };
}
