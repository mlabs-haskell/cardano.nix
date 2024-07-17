{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    craneLib = inputs.crane.mkLib pkgs;
    oura = craneLib.buildPackage {
      src = craneLib.cleanCargoSource inputs.oura;
    };
  in {
    packages = {
      inherit oura;
    };
  };
}
