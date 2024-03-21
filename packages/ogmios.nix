{
  perSystem = {
    system,
    pkgs,
    ...
  }: {
    packages.ogmios = pkgs.stdenv.mkDerivation rec {
      pname = "ogmios";
      version = "6.1.0";
      src = pkgs.fetchurl {
        url = "https://github.com/CardanoSolutions/ogmios/releases/download/v${version}/ogmios-v${version}-${system}.zip";
        hash =
          if system == "x86_64-linux"
          then "sha256-JQJTaws+gihwHpTBtUqcNhgbhFDUAdiiXrO2kMX4ZkY="
          else if system == "aarch64-linux"
          then "sha256-gWNTzUZHdp5rvbU0aIA3/GJ+YZeFx66h05ugJN4kMco="
          else if system == "aarch64-darwin"
          then "sha256-gWNTzUZHdp5rvbU0aIA3/GJ+YZeFx66h05ugJN4kMco="
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
