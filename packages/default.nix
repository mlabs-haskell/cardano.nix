{config, ...}: {
  imports = [
    ./cardano.nix
    ./ogmios.nix
  ];
  flake.overlays = {
    cardano-cli = final: _prev: {inherit ((config.perSystem final.system).packages) cardano-cli;};
    cardano-node = final: _prev: {inherit ((config.perSystem final.system).packages) cardano-node;};
    ogmios = final: _prev: {inherit ((config.perSystem final.system).packages) ogmios;};
  };
}
