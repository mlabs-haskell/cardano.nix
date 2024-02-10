{
  config,
  self,
  inputs,
  ...
}: {
  flake.nixosModules = let
    # Load nixos module, enhancing it's arguments with `self`, `self'`, `inputs` and `system`
    getModule = module: {pkgs, ...}: {
      imports = [module];
      _module.args = let
        inherit (pkgs.stdenv.hostPlatform) system;
      in {
        inherit self system inputs;
        self' = config.perSystem system;
      };
    };
  in {
    globals = getModule ./globals;
    cardano-cli = getModule ./cardano-cli;
    packages = getModule ./packages.nix;
    # the default module imports all modules
    default = {
      imports = with builtins; attrValues (removeAttrs config.flake.nixosModules ["default"]);
    };
    #    stub = { lib }: {
    #      options.cardanoNix = lib.mkOption {
    #        type = lib.types.submoduleWith {
    #          modules = [
    #            { freeformType = lib.types.lazyAttrsOf lib.types.raw; }
    #          ];
    #        };
    #      };
    #    };
  };
}
