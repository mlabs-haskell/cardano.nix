{inputs, ...}: {
  imports = [
    inputs.devshell.flakeModule
    inputs.pre-commit-hooks-nix.flakeModule
  ];

  perSystem = {
    pkgs,
    config,
    self',
    ...
  }: {
    devshells.default = {
      devshell = {
        name = "cardano.nix";
        motd = ''
          ❄️ Welcome to the {14}{bold}cardano.nix{reset}'s shell ❄️
          $(type -p menu &>/dev/null && menu)
          $(type -p update-pre-commit-hooks &>/dev/null && update-pre-commit-hooks)
        '';
      };
      packages = with pkgs; [
        statix
        config.treefmt.build.wrapper
        reuse
        self'.packages.cardano-cli
      ];
      commands = [
        {
          name = "update-pre-commit-hooks";
          command = config.pre-commit.installationScript;
          category = "Tools";
          help = "Update pre-commit-hooks";
        }
      ];
    };
    pre-commit.settings = {
      hooks.treefmt.enable = true;
      settings.treefmt.package = config.treefmt.build.wrapper;
    };
  };
}
