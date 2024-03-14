{
  lib,
  inputs,
  config,
  withSystem,
  ...
}: let
  inherit (lib) mkOption types mapAttrs' nameValuePair;
  inherit (config.flake) nixosModules;
in {
  perSystem = {
    config,
    lib,
    system,
    pkgs,
    ...
  }: let
    cfg = config.nixosTests;
  in {
    options.nixosTests = {
      tests = mkOption {
        description = "NixOS tests as modules.";
        type = types.lazyAttrsOf (types.submodule ({config, ...}: {
          options = {
            name = mkOption {
              description = "The name of the test.";
              type = types.str;
              default = config._module.args.name;
              internal = true;
            };
            systems = mkOption {
              description = "The systems to run the tests on.";
              type = types.listOf types.str;
              default = ["x86_64-linux"];
            };
            module = mkOption {
              description = "The test module. Required.";
              type = types.deferredModule;
            };
            documentation = mkOption {
              description = "Wether to generate documentation for the testnixos configuraion. False by default to speed up builds.";
              type = types.bool;
              default = false;
            };
            specialArgs = mkOption {
              description = "The specialArgs to pass to the test node.";
              type = types.attrsOf types.anything;
              default = {};
            };
            impure = mkOption {
              description = "Wether the test requires internet access and should be run as an effect instead of a nix build.";
              type = types.bool;
              default = false;
            };
            check = mkOption {
              description = "The test derivation composed with _mkCheckFromTest from the module.";
              type = types.package;
              default = cfg._mkCheckFromTest config;
            };
            checkEffect = mkOption {
              description = "The test hercules-ci-effect composed with _mkEffectFromTest from the module.";
              type = types.package;
              default = cfg._mkEffectFromTest config;
            };
          };
        }));
      };
      runTestScript = mkOption {
        type = types.package;
        default = pkgs.callPackage ./run-test.nix {inherit (cfg) tests;};
        description = "A convenience script to run tests";
      };
      _nixosLib = mkOption {
        type = types.anything;
        default = import (inputs.nixpkgs.outPath + "/nixos/lib") {};
        internal = true;
      };
      _mkCheckFromTest = mkOption {
        type = types.functionTo types.package;
        internal = true;
        default = test:
          (cfg._nixosLib.runTest {
            hostPkgs = pkgs;

            defaults.documentation.enable = test.documentation;

            node = {
              inherit (test) specialArgs;
            };

            defaults.imports = [
              # import all of our flake nixos modules by default
              nixosModules.default
              # fix missing pkgs.system in tests
              {nixpkgs.overlays = [(_: _: {inherit system;})];}
            ];

            # import the test module
            imports = [test.module];
          })
          .config
          .result;
      };
      _mkEffectFromTest = mkOption {
        type = types.functionTo types.package;
        internal = true;
        default = test:
          withSystem system ({hci-effects, ...}:
            hci-effects.modularEffect {
              mounts."/dev/kvm" = "kvm";
              effectScript = ''
                ${test.check.driver}/bin/nixos-test-driver
              '';
            });
      };
    };

    config = {
      checks =
        mapAttrs'
        (name: test: nameValuePair "nixosTests-${test.name}" test.check)
        (lib.filterAttrs
          (_: v: lib.elem system v.systems && !v.impure)
          cfg.tests);

      apps.run-test.program = lib.getExe cfg.runTestScript;

      devshells.default.commands = [
        {
          name = "run-test";
          category = "testing";
          help = "Run tests";
          command = "${lib.getExe cfg.runTestScript} $@";
        }
      ];
    };
  };

  herculesCI.onPush.default.outputs.effects =
    mapAttrs'
    (name: test: nameValuePair "nixosTests-${test.name}" test.checkEffect)
    (lib.filterAttrs
      (_: v: lib.elem config.defaultEffectSystem v.systems && v.impure)
      (config.perSystem config.defaultEffectSystem).nixosTests.tests);
}
