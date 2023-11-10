{
  inputs,
  ...
}: {
  imports = [
    ./testing.nix
  ];
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    apps =
      {
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
      }
      // config.cardanoNix.checks;

    devshells.default.commands = [
      {
        category = "Tools";
        name = "build-all";
        help = "Build all the checks";
        command = config.apps.nix-build-all.program;
      }
      {
        category = "Tools";
        name = "check";
        help = "Alias of `nix flake check`";
        command = "nix flake check";
      }
    ];
  };
}
