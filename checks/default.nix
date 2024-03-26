{inputs, ...}: {
  imports = [
    ./vmTests.nix
    ./licenses.nix
  ];
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    apps = {
      nix-build-all.program = pkgs.writeShellApplication {
        name = "nix-build-all";
        runtimeInputs = [
          (pkgs.callPackage inputs.devour-flake {})
        ];
        text = ''
          # Make sure that flake.lock is sync
          nix flake lock --no-update-lock-file

          # Do a full nix build (all outputs)
          devour-flake . "$@"
        '';
      };
    };

    devshells.default.commands = [
      {
        category = "tests";
        name = "build-all";
        help = "build all packages and checks with `devour-flake`";
        command = config.apps.nix-build-all.program;
      }
      {
        category = "tests";
        name = "check";
        help = "run `nix flake check`";
        command = "nix flake check";
      }
    ];
  };
}
