{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      craneLib = inputs.crane.mkLib pkgs;
      oura = craneLib.buildPackage {
        cargoExtraArgs = "--all-features"; # Enable all bundled plugins
        env = {
          OPENSSL_NO_VENDOR = "1"; # Use system openssl
          CARGO_FEATURE_USE_SYSTEM_LIBS = "1"; # Use system gmp/libmpc/mpfs for gmp-mpfr-sys
        };
        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = with pkgs; [
          gmp
          libmpc
          mpfr
          openssl
        ];
        src = inputs.oura;
      };
    in
    {
      packages.oura = oura;
    };
}
