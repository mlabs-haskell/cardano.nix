{ config, ... }:
{
  imports = [
    ./cardano.nix
    ./demeter-run-cli.nix
    ./ogmios.nix
    ./kupo.nix
    ./oura.nix
  ];
  flake.overlays = {
    default = final: _prev: {
      inherit ((config.perSystem final.system).packages)
        cardano-cli
        cardano-node
        demeter-run-cli
        ogmios
        kupo
        oura
        ;
    };
  };
}
