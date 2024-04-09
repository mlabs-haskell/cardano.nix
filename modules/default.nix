{
  inputs,
  config,
  ...
}: {
  flake.nixosModules = {
    cardano = {
      imports = [
        ./cardano.nix
      ];
    };
    cli = {
      imports = [
        ./cli.nix
      ];
      nixpkgs.overlays = [
        config.flake.overlays.cardano-cli
      ];
    };
    node = {
      imports = [
        inputs.cardano-node.nixosModules.cardano-node
        ./node.nix
      ];
      nixpkgs.overlays = [
        config.flake.overlays.cardano-cli
        config.flake.overlays.cardano-node
        config.flake.overlays.cardano-configurations
      ];
    };
    ogmios = {
      imports = [
        ./services/ogmios.nix
        ./ogmios.nix
      ];
      nixpkgs.overlays = [
        config.flake.overlays.ogmios
      ];
    };
    kupo = {
      imports = [
        ./services/kupo.nix
        ./kupo.nix
      ];
      nixpkgs.overlays = [
        config.flake.overlays.kupo
      ];
    };
    http = {
      imports = [
        ./services/http-proxy.nix
        ./http.nix
      ];
    };
    cardano-db-sync = {
      imports = [
        inputs.cardano-db-sync.nixosModules.cardano-db-sync
        ./cardano-db-sync.nix
      ];
    };
    # the default module imports all modules
    default = {
      imports = with builtins; attrValues (removeAttrs config.flake.nixosModules ["default"]);
    };
  };
}
