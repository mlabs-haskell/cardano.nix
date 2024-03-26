{
  inputs,
  lib,
  ...
}: {
  perSystem = {inputs', ...}: {
    packages = lib.filterAttrs (_: v: v != null) {
      cardano-cli = inputs'.cardano-node.packages.cardano-cli or null;
      cardano-node = inputs'.cardano-node.packages.cardano-node or null;
      inherit (inputs') cardano-configurations;
    };
  };
}
