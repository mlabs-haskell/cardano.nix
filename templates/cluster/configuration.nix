{
  system.stateVersion = "24.11";

  cardano = {
    network = "preview";
    node.enable = true;
    ogmios.enable = true;
    kupo.enable = true;
  };
}
