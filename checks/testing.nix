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
  }: {
    ########################################
    ## Implementation
    ########################################
    checks = let
      # import the testing framework
      nixos-lib = import (inputs.nixpkgs.outPath + "/nixos/lib") {};

      # examine the `systems` attribute of each test, filtering out any that do not support the current system
      tests = with lib;
        filterAttrs
        (_: v: elem system v.systems)
        config.cardanoNix.tests;
    in
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

    ########################################
    ## Commands
    ########################################
    devshells.default.commands = [
      {
        name = "tests";
        category = "testing";
        help = "build and run a test";
        command = with lib; ''
          help() {
               # display help
               echo "  build and run a test"
               echo
               echo "  usage:"
               echo "    test <name>"
               echo "    test <name> --interactive"
               echo "    test -s <system> <name>"
               echo
               echo "  arguments:"
               echo "    <name> if a test package is called 'testing-nethermind-basic' then <name> should be 'nethermind-basic'."
               echo
               echo "  options:"
               echo "    -h --help          show this screen."
               echo "    -l --list          show available tests."
               echo "    -s --system        specify the target platform [default: x84_64-linux]."
               echo "    -i --interactive   run the test interactively."
               echo
          }

          list() {
            # display available tests
            echo "  list of available tests:"
            echo
            echo "${strings.concatmapstrings (s: "    - " + s + "\n") (attrsets.mapattrstolist (name: _: (removeprefix "testing-" name)) config.checks)}"
          }

          args=$(getopt -o lihs: --long list,interactive,help,system: -n 'tests' -- "$@")
          eval set -- "$args"

          system="x86_64-linux"
          driver_args=()

          while [ $# -gt 0 ]; do
            case "$1" in
                -i | --interactive) driver_args+=("--interactive"); shift;;
                -s | --system) system="$2"; shift 2;;
                -h | --help) help; exit 0;;
                -l | --list) list; exit 0;;
                -- ) shift; break;;
                * ) break;;
            esac
          done

          if [ $# -eq 0 ]; then
            # no test name has been provided
            help
            exit 1
          fi

          name="$1"
          shift

          # build the test driver
          driver=$(nix build ".#checks.$system.testing-$name.driver" --print-out-paths --no-link)

          # run the test driver, passing any remaining arguments
          set -x
          ''${driver}/bin/nixos-test-driver "''${driver_args[@]}"
        '';
      }
    ];
  };
}
