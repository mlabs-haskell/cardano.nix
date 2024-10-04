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
    default = config.flake.overlays."cardano-node-9.2.1";
    "cardano-node-9.2.1" = final: _prev:
    # overlay for recent packages
    let
      inherit (config.perSystem final.system) packages;
    in {
      cardano-cli = packages."cardano-cli-9.2.1";
      cardano-node = packages."cardano-node-9.2.1";
      cardano-configurations = packages."cardano-configurations-9.2.1";
      ogmios = packages."ogmios-6.6.2";
      kupo = packages."kupo-2.8.0";
      oura = packages."oura-1.9.1";
    };
    "cardano-node-8.1.1" = final: _prev:
    # overlay for packages compatible with cardano-transaction-lib 8.0.0
    let
      inherit (config.perSystem final.system) packages;
    in {
      cardano-cli = packages."cardano-cli-8.1.1";
      cardano-node = packages."cardano-node-8.1.1";
      cardano-configurations = packages."cardano-configurations-8.1.1";
      ogmios = packages."ogmios-6.0.3";
      kupo = packages."kupo-2.6.1";
      oura = packages."oura-1.8.6";
    };
  };
}
