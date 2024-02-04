_: {
  perSystem = {inputs', ...}: {
    packages = {
      # FIXME: this force us into IFD even on `nix flake show`, better to access packages different way
      inherit (inputs'.cardano-node.packages) cardano-cli cardano-node;
    };
  };
}
