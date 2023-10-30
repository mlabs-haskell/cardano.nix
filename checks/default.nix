{inputs, ...}: {
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
        category = "Tools";
        name = "check";
        help = "Build all the checks";
        command = config.apps.nix-build-all.program;
      }
    ];
  };
}
