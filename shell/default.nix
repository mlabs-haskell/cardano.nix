{inputs, ...}: {
  imports = [
    inputs.devshell.flakeModule
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
      };
      packages = with pkgs; [
        statix
        config.treefmt.build.wrapper
      ];
    };
  };
}
