{ inputs, ... }:
{
  imports = [
    inputs.devshell.flakeModule
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      devshells.default = {
        devshell = {
          name = "cardano.nix";
          motd = ''
            ❄️ Welcome to the {14}{bold}cardano.nix{reset} devshell ❄️
            $(menu)
            $(${config.pre-commit.installationScript})
          '';
        };
        packages = with pkgs; [
          statix
          config.treefmt.build.wrapper
          reuse
          git-cliff
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
        hooks.treefmt = {
          enable = true;
          package = config.treefmt.build.wrapper;
        };
      };
    };
}
