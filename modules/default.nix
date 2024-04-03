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
    # the default module imports all modules
    default = {
      imports = with builtins; attrValues (removeAttrs config.flake.nixosModules ["default"]);
    };
  };
}
