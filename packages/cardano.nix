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
      "cardano-cli-8.7.3" = inputs."cardano-node-8.7.3".packages.${system}.cardano-cli or null;
      "cardano-node-8.7.3" = inputs."cardano-node-8.7.3".packages.${system}.cardano-node or null;
      "cardano-configurations-8.7.3" = pkgs.runCommandNoCC "cardano-configurations" {} ''
        ln -s ${inputs."cardano-configurations-8.7.3"} $out
      '';
      "cardano-cli-8.1.1" = inputs."cardano-node-8.1.1".packages.${system}.cardano-cli or null;
      "cardano-node-8.1.1" = inputs."cardano-node-8.1.1".packages.${system}.cardano-node or null;
      "cardano-configurations-8.1.1" = pkgs.runCommandNoCC "cardano-configurations" {} ''
        ln -s ${inputs."cardano-configurations-8.1.1"} $out
      '';
    };
  };
}
