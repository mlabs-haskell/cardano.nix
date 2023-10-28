{
  imports = [
  ];

  # create a default nixos module which mixes in all modules
  flake.nixosModules = {
    global = ./global;
    cardano-cli = ./cardano/cli.nix;
    default = {
      imports = with builtins; attrValues (removeAttrs config.flake.nixosModules ["default"]);
    };
  };
}
