{
  perSystem = {
    system,
    pkgs,
    lib,
    ...
  }: let
    truncateVersion = version: builtins.head (builtins.match "([0-9]+\\.[0-9]+).*" version);
    mkUrl = version: variant: "https://github.com/CardanoSolutions/kupo/releases/download/v${truncateVersion version}/kupo-${version}-${variant}.tar.gz";
    releases = {
      "2.8.0" = {
        "x86_64-linux" = pkgs.fetchurl {
          url = mkUrl "2.8.0" "amd64-Linux";
          hash = "sha256-i4D0tWWBns3+L4UjfA0/UaLNqf4Jxb9v9CLamMnRQ24=";
        };
      };
      "2.6.1" = {
        "x86_64-linux" = pkgs.fetchurl {
          url = mkUrl "2.6.1" "amd64-Linux";
          hash = "sha256-OevKzBwTZSYnm+jKWWCuPRatbc7QqFtgCXeLno0l6M0=";
        };
      };
    };
    mkPackage = version:
      pkgs.runCommandNoCC "kupo-${version}" {inherit version;} ''
        mkdir $out
        cd $out
        ${pkgs.gnutar}/bin/tar -xvzf ${releases.${version}.${system}}
        chmod a+x $out/bin/kupo
      '';
  in {
    packages =
      lib.mapAttrs' (v: _: {
        name = "kupo-${v}";
        value = mkPackage v;
      })
      releases;
  };
}
