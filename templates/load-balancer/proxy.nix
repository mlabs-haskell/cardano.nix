{
  # Enable HTTP proxy and cardano service proxy configuration.
  # See documentation at https://mlabs-haskell.github.io/cardano.nix/reference/module-options/cardano.http/
  cardano.http.enable = true;

  # Configure HTTP proxy.
  # See documentation at https://mlabs-haskell.github.io/cardano.nix/reference/module-options/services.http-proxy/
  services.http-proxy = {
    # # Set domain name for proxy server.
    # # First, make sure to add DNS records for this domain and its subdomains, eg. '*.my.example.com'.
    # # Services will be available under subdomains such as 'ogmios.my.example.com'.
    # domainName = "my.example.com";

    # # Enable HTTPS with Let's Encrypt ACME certificates.
    # # First make sure the server is reachable via the domain name above and its subdomains.
    # https.enable = true;

    # Backend servers to proxy requests to. You may need to use IP addresses here or configure `hosts` entries or set up a DNS server, depending on your network.
    servers = [
      "node1"
      "node2"
      "node3"
    ];

    services.http-proxy.services.grafana.servers = ["status"];
  };

  # Open firewall for prometheus exporter. Don't open this port on the public interface when running in the cloud.
  services.prometheus.exporters.nginx.openFirewall = true;

  # Configure services on separate ports, for easier forwarding from VM. Remove this if DNS is configured.
  networking.firewall.allowedTCPPorts = [81 82 88];
  services.nginx.virtualHosts.ogmios.listen = [
    {
      addr = "0.0.0.0";
      port = 81;
    }
  ];
  services.nginx.virtualHosts.kupo.listen = [
    {
      addr = "0.0.0.0";
      port = 82;
    }
  ];
  services.nginx.virtualHosts.grafana.listen = [
    {
      addr = "0.0.0.0";
      port = 88;
    }
  ];

  # Forward virtual machine port to host. Remove this if running on cloud.
  virtualisation.forwardPorts = [
    {
      from = "host";
      host.port = 8000;
      guest.port = 80;
    }
    {
      from = "host";
      host.port = 8001;
      guest.port = 81;
    }
    {
      from = "host";
      host.port = 8002;
      guest.port = 82;
    }
    {
      from = "host";
      host.port = 8008;
      guest.port = 88;
    }
    {
      from = "host";
      host.port = 2222;
      guest.port = 22;
    }
  ];
}
