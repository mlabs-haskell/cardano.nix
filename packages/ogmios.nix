let
  mkUrl = system: version: "https://github.com/CardanoSolutions/ogmios/releases/download/v${version}/ogmios-v${version}-${system}.zip";
  mkPackage =
    pkgs: version: hash:
    pkgs.fetchzip {
      name = "ogmios-${version}";
      url = mkUrl pkgs.stdenv.hostPlatform.system version;
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
      packages.ogmios = mkPackage pkgs "6.14.0" "sha256-luN05hKGwB00y0mSTGAexi+l7edMfBSEg7WenGEMO6o=";
    };
}
