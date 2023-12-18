{inputs, ...}: {
  imports = [
    inputs.hercules-ci-effects.flakeModule
  ];
  config = {
    hercules-ci.github-pages.branch = "master";
    perSystem = {config, ...}: {
      hercules-ci.github-pages.settings.contents = config.packages.docs;
    };
    herculesCI.ciSystems = ["x86_64-linux" "x86_64-darwin"];
  };
}
