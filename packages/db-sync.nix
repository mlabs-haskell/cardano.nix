{
  perSystem =
    { inputs', ... }:
    {
      packages = {
        cardano-db-sync = inputs'.cardano-db-sync.packages."cardano-db-sync:exe:cardano-db-sync";
        cardano-db-tool = inputs'.cardano-db-sync.packages."cardano-db-tool:exe:cardano-db-tool";
      };
    };
}
