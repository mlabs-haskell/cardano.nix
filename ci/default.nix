{inputs, ...}: {
  imports = [
    inputs.hercules-ci-effects.flakeModule
    "${inputs.hercules-ci-effects}/effects/push-cache/default.nix"
  ];
  config = {
    hercules-ci.github-pages.branch = "master";
    perSystem = {config, ...}: {
      hercules-ci.github-pages.settings.contents = config.packages.docs;
    };
    herculesCI.ciSystems = ["x86_64-linux" "x86_64-darwin"];

    push-cache-effect = {
      enable = true;
      attic-client-pkg = inputs.attic.packages.x86_64-linux.attic-client;
      caches = {
        mlabs-cardano-nix = {
          type = "attic";
          secretName = "cardano-nix-cache-push-token";
          packages = [inputs.nixpkgs.legacyPackages.x86_64-linux.hello];
        };
      };
    };
  };
}
