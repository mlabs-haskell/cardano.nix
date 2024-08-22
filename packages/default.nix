{config, ...}: {
  imports = [
    ./cardano.nix
    ./ogmios.nix
    ./kupo.nix
    ./oura.nix
    # TODO add support for multiple blockfrost versions and re-export derivations from this flake
  ];
  perSystem = {system, ...}: {
    # add default package versions under attribute names without version
    packages = config.flake.overlays.default {inherit system;} {};
  };
  flake.overlays = {
    default = config.flake.overlays."cardano-node-9.1.0";
    "cardano-node-9.1.0" = final: _prev:
    # overlay for recent packages
    let
      inherit (config.perSystem final.system) packages;
    in {
      cardano-cli = packages."cardano-cli-9.1.0";
      cardano-node = packages."cardano-node-9.1.0";
      cardano-configurations = packages."cardano-configurations-9.1.0";
      ogmios = packages."ogmios-6.1.0";
      kupo = packages."kupo-2.9.0";
      oura = packages."oura-1.9.0";
    };
  };
}
