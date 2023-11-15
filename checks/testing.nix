{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkOption types mapAttrs' nameValuePair;
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
        };
      }));
    };
  };

  config.perSystem = {
    lib,
    system,
    pkgs,
    ...
  } @ perSystemArgs: {
    options.cardanoNix.runTestScript = mkOption {
      type = types.package;
      default = pkgs.callPackage ./run-test.nix {inherit (config.cardanoNix) tests;};
      description = "A convenience script to run tests";
      internal = true;
    };

    config = let
      nixos-lib = import (inputs.nixpkgs.outPath + "/nixos/lib") {};
      tests =
        lib.filterAttrs
        (_: v: lib.elem system v.systems)
        config.cardanoNix.tests;

      inherit (perSystemArgs.config.cardanoNix) runTestScript;
    in {
      checks =
        mapAttrs'
        (name: test:
          nameValuePair "testing-${test.name}"
          (nixos-lib.runTest {
            hostPkgs = pkgs;

            # speed up evaluation by skipping docs
            defaults.documentation.enable = lib.mkDefault false;

            # make self available in test modules and our custom pkgs
            node.specialArgs = {
              inherit pkgs;
            };

            # import all of our flake nixos modules by default
            defaults.imports = [
              config.flake.nixosModules.default
            ];

            # import the test module
            imports = [test.module];
          })
          .config
          .result)
        tests;

      apps.run-test.program = lib.getExe runTestScript;

      devshells.default.commands = [
        {
          name = "run-test";
          category = "testing";
          help = "Run tests";
          command = "${lib.getExe runTestScript} $@";
        }
      ];
    };
  };
}
