{
  cardano = {
    network = "preview";
    node.enable = true;
    ogmios.enable = true;
    kupo.enable = true;
    db-sync.enable = true;
    oura.enable = true;
    blockfrost.enable = true;
    http.enable = true;
    monitoring.enable = true;
    # monitoring.hosts = [ "localhost" ];
  };

  networking.firewall.allowedTCPPorts = [
    3000
    9090
  ];

  virtualisation.memorySize = 8192;

  virtualisation.forwardPorts = [
    {
      # prometheus
      from = "host";
      host.port = 9090;
      guest.port = 9090;
    }
    {
      # grafana
      from = "host";
      host.port = 3000;
      guest.port = 3000;
    }
  ];
}
