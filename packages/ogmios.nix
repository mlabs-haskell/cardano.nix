{
  perSystem = {
    system,
    pkgs,
    ...
  }: {
    # Doesn't buid with haskell.nix but master contains a fix. Move to haskell.nix build on next release.
    packages.ogmios = pkgs.stdenv.mkDerivation rec {
      pname = "ogmios";
      version = "6.2.0";
      src = pkgs.fetchurl {
        url = "https://github.com/CardanoSolutions/ogmios/releases/download/v${version}/ogmios-v${version}-${system}.zip";
        hash =
          if system == "x86_64-linux"
          then "sha256-Ryfuzu7JzbR7ivh2Sl9xyOuWh4btjCVSPhXfDLmepHk=u"
          else if system == "aarch64-linux"
          then "sha256-SJQWbIkXF2e4jJtq2hQFqSPO/EhbmLYeZx3aEaXv/gI="
          else abort "Ogmios release not available for system ${system}";
      };
      nativeBuildInputs = [pkgs.unzip];
      unpackPhase = ''
        unzip $src
      '';
      buildPhase = ''
        chmod a+x bin/ogmios
      '';
      installPhase = ''
        mkdir -p $out
        mv bin share $out/
      '';
    };
  };
}
