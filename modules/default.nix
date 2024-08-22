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
    };
    node = {
      imports = [
        inputs."cardano-node-9.1.0".nixosModules.cardano-node
        ./node.nix
      ];
    };
    ogmios = {
      imports = [
        ./services/ogmios.nix
        ./ogmios.nix
      ];
    };
    kupo = {
      imports = [
        ./services/kupo.nix
        ./kupo.nix
      ];
    };
    http = {
      imports = [
        ./services/http-proxy.nix
        ./http.nix
      ];
    };
    db-sync = {
      imports = [
        inputs.cardano-db-sync.nixosModules.cardano-db-sync
        ./db-sync.nix
      ];
    };
    blockfrost = {
      imports = [
        inputs.blockfrost.nixosModules.default
        ./blockfrost.nix
      ];
    };
    oura = {
      imports = [
        ./oura.nix
        ./services/oura.nix
      ];
    };
    # the default module imports all modules
    default = {
      imports =
        [
          {
            nixpkgs.overlays = [config.flake.overlays.default];
          }
        ]
        ++ (with builtins;
            attrValues (removeAttrs config.flake.nixosModules ["default"]));
    };
  };
}
