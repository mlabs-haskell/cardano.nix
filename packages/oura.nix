{inputs, ...}: {
  perSystem = {system, ...}: {
    packages = {
      inherit (inputs.oura.packages.${system}) oura;
    };
  };
}
