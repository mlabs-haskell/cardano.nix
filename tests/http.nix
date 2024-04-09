{
  perSystem.vmTests.tests.http = {
    impure = true;
    module = {
      nodes.node = {config, ...}: {
        cardano = {
          network = "preview";
          node.enable = true;
          ogmios.enable = true;
        };
        services.ogmios.host = "0.0.0.0";
        networking.firewall.allowedTCPPorts = [config.services.ogmios.port];
      };

      nodes.proxy = {
        cardano = {
          http.enable = true;
        };
        services.http-proxy.servers = ["node"];
      };

      nodes.client = {pkgs, ...}: {
        environment.systemPackages = [pkgs.curl];
      };

      testScript = {nodes, ...}: ''
        start_all()
        node.wait_for_unit("ogmios")
        node.wait_until_succeeds('curl --fail http://127.0.0.1:1337/health')
        proxy.wait_for_unit("nginx")
        client.wait_until_succeeds('curl --fail -H "Host: ogmios" http://proxy/health')
        client.succeed('[ "${nodes.node.services.ogmios.package.version}" == "$(curl --silent --fail -H "Host: ogmios" http://proxy/version)" ]')
      '';
    };
  };
}
