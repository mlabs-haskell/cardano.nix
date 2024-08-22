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
      "cardano-cli-9.1.0" = inputs."cardano-node-9.1.0".packages.${system}.cardano-cli or null;
      "cardano-node-9.1.0" = inputs."cardano-node-9.1.0".packages.${system}.cardano-node or null;
      "cardano-configurations-9.1.0" = pkgs.runCommandNoCC "cardano-configurations" {} ''
        ln -s ${inputs."cardano-configurations-9.1.0"} $out
      '';
    };
  };
}
