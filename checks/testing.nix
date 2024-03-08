{
  lib,
  inputs,
  config,
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
    cfg = config.cardanoNix;
  in {
    options.cardanoNix = {
      tests = mkOption {
        type = types.lazyAttrsOf (types.submodule ({config, ...}: {
          options = {
            name = mkOption {
              type = types.str;
              default = config._module.args.name;
              internal = true;
            };
            systems = mkOption {
              type = types.listOf types.str;
            };
            module = mkOption {
              type = types.deferredModule;
            };
            documentation = mkOption {
              type = types.bool;
              default = false;
            };
            specialArgs = mkOption {
              type = types.attrsOf types.anything;
              default = {};
            };
            impure = mkOption {
              type = types.bool;
              default = false;
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

            # false by default, it speeds up evaluation by skipping docs generation
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
    };

    config = {
      checks =
        mapAttrs'
        (name: test: nameValuePair "testing-${test.name}" (cfg._mkCheckFromTest test))
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
}
