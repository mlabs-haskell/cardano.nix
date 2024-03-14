{
  inputs,
  config,
  ...
}: {
  flake.nixosModules = rec {
    globals = ./globals;
    cardano-node = {
      imports = [
        inputs.cardano-node.nixosModules.cardano-node
        cardano-overlay
        ./cardano-node
      ];
    };
    cardano-cli = {
      imports = [
        cardano-overlay
        ./cardano-cli
      ];
    };
    cardano-overlay = {
      nixpkgs.overlays = [config.flake.overlays.default];
    };
    # the default module imports all modules
    default = {
      imports = with builtins; attrValues (removeAttrs config.flake.nixosModules ["default"]);
    };
  };
}
