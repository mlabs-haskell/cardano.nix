{
  config,
  self,
  inputs,
  ...
}: {
  flake.nixosModules = {
    inject-args = {
      pkgs,
      lib,
      ...
    }: {
      _module.args = let
        inherit (pkgs.stdenv.hostPlatform) system;
      in {
        inherit self system inputs;
        self' = lib.mkForce (config.perSystem system);
      };
    };
    globals = ./globals;
    cardano-block-producer = ./cardano-node/producer.nix;
    cardano-node-instance = ./cardano-node/instance.nix;
    cardano-cli = ./cardano-cli;
    packages = ./packages.nix;
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
