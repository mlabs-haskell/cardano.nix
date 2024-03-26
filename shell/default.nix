{inputs, ...}: {
  imports = [
    inputs.devshell.flakeModule
    inputs.pre-commit-hooks-nix.flakeModule
  ];

  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devshells.default = {
      devshell = {
        name = "cardano.nix";
        motd = ''
          ❄️ Welcome to the {14}{bold}cardano.nix{reset} devshell ❄️
          $(type -p menu &>/dev/null && menu)
          $(type -p update-pre-commit-hooks &>/dev/null && update-pre-commit-hooks)
        '';
      };
      packages = with pkgs; [
        statix
        config.treefmt.build.wrapper
        reuse
      ];
      commands = [
        {
          name = "update-pre-commit-hooks";
          command = config.pre-commit.installationScript;
          category = "tools";
          help = "update git pre-commit hooks";
        }
      ];
    };
    pre-commit.settings = {
      hooks.treefmt.enable = true;
      settings.treefmt.package = config.treefmt.build.wrapper;
    };
  };
}
