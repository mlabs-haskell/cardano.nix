{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    craneLib = inputs.crane.mkLib pkgs;
    oura = craneLib.buildPackage {
      cargoExtraArgs = "--all-features"; # Enable all bundled plugins
      nativeBuildInputs = [pkgs.perl]; # Adding perl fixing build of vendored openssl inside `openssl-sys` crate
      src = craneLib.cleanCargoSource inputs.oura;
    };
  in {
    packages = {
      "oura-${oura.version}" = oura;
    };
  };
}
