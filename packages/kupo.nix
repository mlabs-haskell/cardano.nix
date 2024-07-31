{
  perSystem = {
    system,
    pkgs,
    lib,
    ...
  }: let
    truncateVersion = version: builtins.head (builtins.match "v?([0-9]+\\.[0-9]+).*" version);
    mkUrl = version: variant: archive: "https://github.com/CardanoSolutions/kupo/releases/download/v${truncateVersion version}/kupo-${version}-${variant}.${archive}";
    releases = {
      "2.9.0" = {
        "x86_64-linux" = {
          url = mkUrl "v2.9.0" "x86_64-linux" "zip";
          hash = "sha256-sEfaFPph1qBuPrxQzFeTKU/9i9w0KF/v7GpxxmorPWQ=";
        };
      };
      "2.8.0" = {
        "x86_64-linux" = {
          url = mkUrl "2.8.0" "amd64-Linux" "tar.gz";
          hash = "sha256-k6js0R0psyeHnM6q0e4slu4ESXm1FMiVRO2JUlsnlHY=";
        };
      };
      "2.6.1" = {
        "x86_64-linux" = {
          url = mkUrl "2.6.1" "amd64-Linux" "tar.gz";
          hash = "sha256-pK+1ncKirqoTcC42pR5x0Oc9xXCAm2ajt9oRWZjNeyQ=";
        };
      };
    };
    mkPackage = version:
      pkgs.fetchzip {
        inherit (releases.${version}.${system}) url hash;
        stripRoot = false;
        name = "kupo-${version}";
        postFetch = "chmod +x $out/bin/kupo";
      }
      // {inherit version;};
  in {
    packages =
      lib.mapAttrs' (v: _: {
        name = "kupo-${v}";
        value = mkPackage v;
      })
      releases;
  };
}
