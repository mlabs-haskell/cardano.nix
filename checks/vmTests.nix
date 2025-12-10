{
  lib,
  inputs,
  config,
  withSystem,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mapAttrs'
    nameValuePair
    ;
  inherit (config.flake) nixosModules;
in
{
  perSystem =
    {
      config,
      lib,
      system,
      pkgs,
      ...
    }:
    let
      cfg = config.vmTests;
    in
    {
      options.vmTests = {
        tests = mkOption {
          description = "Run integration tests in networks of virtual machines.";
          type = types.lazyAttrsOf (
            types.submodule (
              { config, ... }:
              {
                options = {
                  name = mkOption {
                    description = "The name of the test. Defaults to attribute name.";
                    internal = true;
                    type = types.str;
                    default = config._module.args.name;
                  };
                  systems = mkOption {
                    description = "The systems to run the test on.";
                    type = types.listOf types.str;
                    default = [ "x86_64-linux" ];
                  };
                  module = mkOption {
                    description = "The NixOS test module. Required. See https://nixos.org/manual/nixos/stable/#sec-nixos-tests .";
                    type = types.deferredModule;
                  };
                  impure = mkOption {
                    description = "Wether the test requires internet access and should be run as an effect instead of a nix build.";
                    type = types.bool;
                    default = false;
                  };
                  check = mkOption {
                    description = "The test derivation. Result of calling `_mkCheck` with this test.";
                    type = types.package;
                    default = cfg._mkCheck config;
                  };
                  effect = mkOption {
                    description = "The test hercules-ci-effect. Result of calling `_mkEffect` with this test.";
                    type = types.package;
                    default = cfg._mkEffect config;
                  };
                };
              }
            )
          );
        };
        runVmTestScript = mkOption {
          description = "Script that lists and runs integration tests on networks of virtual machines.";
          type = types.package;
          default = pkgs.callPackage ./run-vm-test.nix { inherit (cfg) tests; };
        };
        _nixosLib = mkOption {
          description = "Convenience access to `nixpkgs/nixos/lib`.";
          internal = true;
          type = types.anything;
          default = import (inputs.nixpkgs.outPath + "/nixos/lib") { };
        };
        _mkCheck = mkOption {
          description = "Function that takes a test `module` and returns a derivation that runs the test when built.";
          internal = true;
          type = types.functionTo types.package;
          default =
            test:
            (cfg._nixosLib.runTest {
              name = lib.mkDefault test.name;
              imports = [ test.module ];
              hostPkgs = pkgs;
              defaults = {
                imports = [
                  # Import all of our NixOS modules by default.
                  nixosModules.default
                  # Fix missing `pkgs.system` in tests.
                  { nixpkgs.overlays = [ (_: _: { inherit (pkgs.stdenv.hostPlatform) system; }) ]; }
                ];
                documentation.enable = lib.mkDefault false;
              };
            }).config.result;
        };
        _mkEffect = mkOption {
          description = "Function that takes a test `module` and returns a Hercules CI effect that runs the test.";
          internal = true;
          type = types.functionTo types.package;
          default =
            testModule:
            withSystem system (
              { hci-effects, ... }:
              hci-effects.modularEffect {
                mounts."/dev/kvm" = "kvm";
                effectScript = ''
                  ${testModule.check.driver}/bin/nixos-test-driver
                '';
              }
            );
        };
      };

      config = {
        checks = mapAttrs' (_name: test: nameValuePair "vmTests-${test.name}" test.check) (lib.filterAttrs (_: v: lib.elem system v.systems && !v.impure) cfg.tests);

        apps = {
          run-vm-tests.program = lib.getExe cfg.runVmTestScript;
        }
        // mapAttrs' (_name: test: nameValuePair "vmTests-${test.name}" { program = "${test.check.driver}/bin/nixos-test-driver"; }) (lib.filterAttrs (_: v: lib.elem system v.systems) cfg.tests);

        devshells.default.commands = [
          {
            name = "run-vm-test";
            category = "tests";
            help = "list and run virtual machine integration tests";
            command = "${lib.getExe cfg.runVmTestScript} $@";
          }
        ];
      };
    };

  herculesCI.onPush.default.outputs.effects = mapAttrs' (_name: test: nameValuePair "vmTests-${test.name}" test.effect) (lib.filterAttrs (_: v: lib.elem config.defaultEffectSystem v.systems && v.impure) (config.perSystem config.defaultEffectSystem).vmTests.tests);
}
