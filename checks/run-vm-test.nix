{
  writeShellApplication,
  lib,
  tests,
  stdenv,
  ...
}:
writeShellApplication {
  name = "run-vm-test";

  runtimeInputs = [ ];

  text = ''
    cmd_name=$(basename "$0")

    help() {
      echo "  Build and run integration test on a network of virtual machines."
      echo
      echo "  Usage:"
      echo "    $cmd_name <name>"
      echo "    $cmd_name <name> --interactive"
      echo "    $cmd_name -s <system> <name>"
      echo
      echo "  Arguments:"
      echo "    <name>"
      echo
      echo "  Options:"
      echo "    -h --help          Show this screen."
      echo "    -l --list          Show available tests."
      echo "    -s --system        Specify the target platform [default: ${stdenv.hostPlatform.system}]."
      echo "    -i --interactive   Run the test interactively."
      echo
    }

    list() {
      echo "  list of available tests:"
      echo
      echo "${lib.concatMapStrings (s: "    - " + s + "\n") (lib.mapAttrsToList (_: test: test.name) tests)}"
    }

    args=$(getopt -o lihs: --long list,interactive,help,system: -n 'tests' -- "$@")
    eval set -- "$args"

    system="${stdenv.hostPlatform.system}"
    nix_args="''${NIX_ARGS:=}"
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
      help
      exit 1
    fi

    name="$1"
    shift

    # build/run the test driver, passing any remaining arguments
     # shellcheck disable=SC2068,SC2086
    nix run ".#apps.$system.vmTests-$name" ''${nix_args} -- ''${driver_args[@]}
  '';
}
