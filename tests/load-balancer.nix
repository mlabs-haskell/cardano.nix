let
  node = {config, ...}: {
    cardano = {
      network = "preview";
      node.enable = true;
      ogmios.enable = true;
    };
    services.ogmios.host = "0.0.0.0";
    networking.firewall.allowedTCPPorts = [config.services.ogmios.port];
  };
in {
  perSystem.vmTests.tests.load-balancer = {
    impure = true;
    module = {
      nodes.node1 = node;

      nodes.node2 = node;

      nodes.node3 = node;

      nodes.proxy = {
        cardano.http.enable = true;
        services.http-proxy.servers = ["node1" "node2" "node3"];

        virtualisation.forwardPorts = [
          {
            from = "host";
            host.port = 8000;
            guest.port = 80;
          }
        ];
      };

      nodes.client = {pkgs, ...}: {
        environment.systemPackages = [pkgs.curl pkgs.iproute2];
      };

      testScript = {nodes, ...}: ''
        start_all()
        node1.wait_for_unit("ogmios")
        node1.wait_until_succeeds('curl --silent --fail http://127.0.0.1:1337/health')
        proxy.wait_for_unit("nginx")
        client.wait_until_succeeds('curl --silent --fail -H "Host: ogmios" http://proxy/health')
        client.succeed('[ "${nodes.node1.services.ogmios.package.version}" == "$(curl --silent --fail -H "Host: ogmios" http://proxy/version)" ]')
      '';
    };
  };
}
