{config, ...}: let
  mkOverlay = name: (
    final: _prev: {${name} = (config.perSystem final.system).packages.${name};}
  );
in {
  imports = [
    ./cardano.nix
    ./ogmios.nix
  ];
  flake.overlays = {
    cardano-cli = mkOverlay "cardano-cli";
    cardano-node = mkOverlay "cardano-node";
    cardano-configurations = mkOverlay "cardano-configurations";
    ogmios = mkOverlay "ogmios";
  };
}
