{config, ...}: {
  flake.nixosModules = {
    globals = ./globals;
    cardano-cli = ./cardano-cli;
    # the default module imports all modules
    default = {
      imports = with builtins; attrValues (removeAttrs config.flake.nixosModules ["default"]);
    };
  };
}
