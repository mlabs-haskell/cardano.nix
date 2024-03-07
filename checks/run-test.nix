{
  writeShellApplication,
  lib,
  tests,
  stdenv,
  ...
}:
writeShellApplication {
  name = "run-test";

  runtimeInputs = [];

  text = ''
    cmd_name=$(basename "$0")

    help() {
      echo "  build and run a test"
      echo
      echo "  usage:"
      echo "    $cmd_name <name>"
      echo "    $cmd_name <name> --interactive"
      echo "    $cmd_name -s <system> <name>"
      echo
      echo "  arguments:"
      echo "    <name>"
      echo
      echo "  options:"
      echo "    -h --help          show this screen."
      echo "    -l --list          show available tests."
      echo "    -s --system        specify the target platform [default: ${stdenv.system}]."
      echo "    -i --interactive   run the test interactively."
      echo
    }

    list() {
      echo "  list of available tests:"
      echo
      echo "${lib.concatMapStrings (s: "    - " + s + "\n") (lib.mapAttrsToList (_: test: test.name) tests)}"
    }

    args=$(getopt -o lihs: --long list,interactive,help,system: -n 'tests' -- "$@")
    eval set -- "$args"

    system="${stdenv.system}"
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
    nix run ".#checks.$system.testing-$name.driver" "''${nix_args}" -- "''${driver_args[@]}"
  '';
}
