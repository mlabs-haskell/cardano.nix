{
  cardano.monitoring = {
    enable = true;
    targets = ["proxy" "status" "node1" "node2" "node3"];
  };

  # Grafana listen address. When running in cloud, set to internal IP address.
  services.grafana.settings.server.http_addr = "0.0.0.0";
}
