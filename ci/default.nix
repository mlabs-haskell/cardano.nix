{inputs, ...}: {
  imports = [
    inputs.hercules-ci-effects.flakeModule
  ];
  config.herculesCI.ciSystems = ["x86_64-linux" "x86_64-darwin"];
}
