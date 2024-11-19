{ config, ... }:
{
  imports = [
    ./cardano.nix
    ./ogmios.nix
    ./kupo.nix
    ./oura.nix
  ];
  flake.overlays = {
    default = final: _prev: {
      inherit ((config.perSystem final.system).packages)
        cardano-cli
        cardano-node
        ogmios
        kupo
        oura
        ;
    };
  };
}
