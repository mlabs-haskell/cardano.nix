{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.easyOverlay];
  perSystem = {
    config,
    system,
    lib,
    ...
  }: {
    packages = let
      packageNames = ["cardano-node" "cardano-cli"];
    in
      lib.filterAttrs (n: _: builtins.elem n packageNames) (inputs.cardano-node.packages.${system} or {});
    overlayAttrs = config.packages;
  };
}
