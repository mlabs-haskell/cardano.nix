{
  inputs,
  lib,
  ...
}: {
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
          ❄️ Welcome to the {14}{bold}cardano.nix{reset}'s shell ❄️
          $(type -p menu &>/dev/null && menu)
        '';
        startup = {
          pre-commit = lib.noDepEntry "eval ${config.pre-commit.installationScript}";
        };
      };
      packages = with pkgs; [
        statix
        config.treefmt.build.wrapper
        reuse
      ];
    };
    pre-commit.settings = {
      hooks.treefmt.enable = true;
      settings.treefmt.package = config.treefmt.build.wrapper;
    };
  };
}
