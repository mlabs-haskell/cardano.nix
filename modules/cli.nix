{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cardano.cli.enable = lib.mkOption {
    description = "Add cardano-cli to 'environment.systemPackages'.";
    type = lib.types.bool;
    default = config.cardano.enable or config.cardano.node.enable or false;
  };

  config = lib.mkIf config.cardano.cli.enable {
    environment.systemPackages = [pkgs.cardano-cli];
  };
}
