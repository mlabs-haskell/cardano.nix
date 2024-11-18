let
  mkUrl = system: version: "https://github.com/CardanoSolutions/ogmios/releases/download/v${version}/ogmios-v${version}-${system}.zip";
  mkPackage =
    pkgs: version: hash:
    pkgs.fetchzip {
      name = "ogmios-${version}";
      url = mkUrl pkgs.system version;
      inherit hash;
      stripRoot = false;
      postFetch = "chmod +x $out/bin/ogmios";
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
      packages.ogmios = mkPackage pkgs "6.8.0" "sha256-PM3tB6YdFsXRxGptDuxOvLke0m/08ySy4oV1WfIu//g=";
    };
}
