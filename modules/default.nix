{config, ...}: {
  # FIXME: two approaches
  #        1st -- we keep all modules in `parts` level, to have access to self/packages/etc
  #          cardano-cli is example of first approach
  #        2nd -- we keep only ./packages.nix in `parts` level, because it require access to self.packages/self.inputs
  #          package.nix re-export packages as `cardanoNix.packages` options set.
  imports = [
    ./cardano-cli
    ./packages.nix
  ];
  flake.nixosModules = {
    # FIXME for second approach all modules except packages.nix should be imported here
    globals = ./globals;
    # the default module imports all modules
    default = {
      imports = with builtins; attrValues (removeAttrs config.flake.nixosModules ["default"]);
    };
  };
}
