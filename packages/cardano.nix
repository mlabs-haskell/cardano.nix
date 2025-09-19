{
  perSystem =
    { inputs', ... }:
    {
      packages = {
        inherit (inputs'.cardano-node.packages) cardano-cli cardano-node;
      };
    };
}
