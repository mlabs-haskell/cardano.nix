let
  truncateVersion = version: builtins.head (builtins.match "v?([0-9]+\\.[0-9]+).*" version);
  mkUrl = system: version: "https://github.com/CardanoSolutions/kupo/releases/download/v${truncateVersion version}/kupo-v${version}-${system}.zip";
  mkPackage =
    pkgs: version: hash:
    pkgs.fetchzip {
      url = mkUrl pkgs.stdenv.hostPlatform.system version;
      inherit hash;
      stripRoot = false;
      name = "kupo-${version}";
      postFetch = "chmod +x $out/bin/kupo";
    }
    // {
      inherit version;
      inherit mkPackage;
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.kupo = mkPackage pkgs "2.11.0" "sha256-kOYenPdLEYwub4obEsgMEkytZQN/9CF64pfeS1Jr5QY=";
    };
}
