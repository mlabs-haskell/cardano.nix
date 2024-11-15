let
  truncateVersion = version: builtins.head (builtins.match "v?([0-9]+\\.[0-9]+).*" version);
  mkUrl = system: version: "https://github.com/CardanoSolutions/kupo/releases/download/v${truncateVersion version}/kupo-${version}-${system}.zip";
  mkPackage = pkgs: version: hash:
    pkgs.fetchzip
    {
      url = mkUrl pkgs.system version;
      inherit hash;
      stripRoot = false;
      name = "kupo-${version}";
      postFetch = "chmod +x $out/bin/kupo";
    }
    // {
      inherit version;
      inherit mkPackage;
    };
in {
  perSystem = {pkgs, ...}: {
    packages.kupo = mkPackage pkgs "2.9.0" "sha256-sEfaFPph1qBuPrxQzFeTKU/9i9w0KF/v7GpxxmorPWQ=";
  };
}
