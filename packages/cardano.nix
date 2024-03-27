{
  inputs,
  lib,
  ...
}: {
  perSystem = {system, ...}: {
    packages = lib.filterAttrs (_: v: v != null) {
      cardano-cli = inputs.cardano-node.packages.${system}.cardano-cli or null;
      cardano-node = inputs.cardano-node.packages.${system}.cardano-node or null;
      inherit (inputs) cardano-configurations;
    };
  };
}
