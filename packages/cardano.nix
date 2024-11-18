{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      packages = {
        inherit (inputs.cardano-node.packages.${system}) cardano-cli cardano-node;
      };
    };
}
