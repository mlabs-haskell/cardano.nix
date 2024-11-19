{ config, ... }:
{
  cardano = {
    network = "preview";
    node.enable = true;
    ogmios.enable = true;
    kupo.enable = true;
  };
  services.ogmios.host = "0.0.0.0";
  services.kupo.host = "0.0.0.0";
  networking.firewall.allowedTCPPorts = [
    config.services.ogmios.port
    config.services.kupo.port
  ];
}
