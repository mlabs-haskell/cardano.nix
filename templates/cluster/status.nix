{
  cardano.monitoring = {
    enable = true;
    targets = [
      "proxy"
      "status"
      "node1"
      "node2"
      "node3"
    ];
  };

  # Grafana listen address. Do not expose this service publicly when running in the cloud, instead use the load balancer to proxy with HTTPS.
  services.grafana.settings.server.http_addr = "0.0.0.0";
}
