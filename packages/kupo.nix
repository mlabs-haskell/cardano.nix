{
  perSystem = {
    system,
    pkgs,
    ...
  }: {
    packages.kupo = let
      version = "2.8.0";
      mkUrl = variant: "https://github.com/CardanoSolutions/kupo/releases/download/v2.8/kupo-${version}-${variant}.tar.gz";
      src =
        pkgs.fetchurl
        {
          "x86_64-linux" = {
            url = mkUrl "amd64-Linux";
            hash = "sha256-i4D0tWWBns3+L4UjfA0/UaLNqf4Jxb9v9CLamMnRQ24=";
          };
          "aarch64-linux" = {
            url = mkUrl "arm64-Linux";
            hash = "sha256-BpUD476g3Ilyv1CWyh1JSYIly8YIrXro+UQe9Pk/Teo=";
          };
        }
        .${system};
    in
      pkgs.runCommandNoCC "kupo-${version}" {inherit version;} ''
        mkdir $out
        cd $out
        ${pkgs.gnutar}/bin/tar -xvzf ${src}
        chmod a+x $out/bin/kupo
      '';
  };
}
