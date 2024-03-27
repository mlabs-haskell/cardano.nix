{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.hercules-ci-effects.flakeModule
    "${inputs.hercules-ci-effects}/effects/push-cache/default.nix"
  ];
  config = {
    hercules-ci.github-pages.branch = "master";
    hercules-ci.flake-update = {
      enable = true;
      when = {
        dayOfWeek = "Sun";
        hour = 12;
        minute = 45;
      };
    };

    perSystem = {config, ...}: {
      hercules-ci.github-pages.settings.contents = config.packages.docs;
    };

    push-cache-effect = {
      enable = true;
      attic-client-pkg = inputs.attic.packages.x86_64-linux.attic-client;
      caches = {
        mlabs-cardano-nix = {
          type = "attic";
          secretName = "cardano-nix-cache-push-token";
          packages = with lib;
            flatten [
              (forEach ["apps" "devShells" "packages"]
                (attr:
                  forEach config.systems
                  (system:
                    collect isDerivation (config.flake.${attr}.${system} or {}))))
              (forEach (attrValues config.flake.nixosConfigurations)
                (os:
                  os.config.system.build.toplevel))
            ];
        };
      };
    };
  };
}
