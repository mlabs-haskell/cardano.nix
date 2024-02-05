{config, ...}: {
  imports = [./cardano-cli];
  flake.nixosModules = {
    globals = ./globals;
    # the default module imports all modules
    default = {
      imports = with builtins; attrValues (removeAttrs config.flake.nixosModules ["default"]);
    };
  };
}
