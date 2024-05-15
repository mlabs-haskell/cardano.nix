{
  perSystem = {
    system,
    pkgs,
    ...
  }: {
    packages.ogmios = let
      version = "6.1.0";
      src = pkgs.fetchurl {
        url = "https://github.com/CardanoSolutions/ogmios/releases/download/v${version}/ogmios-v${version}-${system}.zip";
        hash =
          {
            "x86_64-linux" = "sha256-JQJTaws+gihwHpTBtUqcNhgbhFDUAdiiXrO2kMX4ZkY=";
            "aarch64-linux" = "sha256-gWNTzUZHdp5rvbU0aIA3/GJ+YZeFx66h05ugJN4kMco=";
          }
          .${system};
      };
    in
      pkgs.runCommandNoCC "ogmios-${version}" {
        inherit version;
        meta.mainProgram = "ogmios";
      } ''
        mkdir $out
        cd $out
        ${pkgs.unzip}/bin/unzip ${src}
        chmod a+x $out/bin/ogmios
      '';
  };
}
