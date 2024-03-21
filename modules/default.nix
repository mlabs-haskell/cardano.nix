{
  inputs,
  config,
  ...
}: {
  flake.nixosModules = rec {
    globals = ./globals;
    cardano-cli = {
      imports = [./cardano-cli];
      nixpkgs.overlays = [config.flake.overlays.cardano-cli];
    };
    cardano-node = {
      imports = [
        inputs.cardano-node.nixosModules.cardano-node
        ./cardano-node
      ];
      nixpkgs.overlays = [
        config.flake.overlays.cardano-cli
        config.flake.overlays.cardano-node
      ];
    };
    # the default module imports all modules
    default = {
      imports = with builtins; attrValues (removeAttrs config.flake.nixosModules ["default"]);
    };
  };
}
