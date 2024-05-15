{
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages = lib.filterAttrs (_: v: v != null) {
      cardano-cli = inputs.cardano-node.packages.${system}.cardano-cli or null;
      cardano-node = inputs.cardano-node.packages.${system}.cardano-node or null;
      # turn path into proper derivation
      cardano-configurations = pkgs.runCommandNoCC "cardano-configurations" {} ''
        ln -s ${inputs.cardano-configurations} $out
      '';
    };
  };
}
