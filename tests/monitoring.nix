{
  perSystem.vmTests.tests.monitoring = {
    impure = true;
    module = {
      nodes.machine =
        { pkgs, ... }:
        {
          cardano = {
            network = "preview";
            node.enable = true;
            monitoring.enable = true;
          };

          environment.systemPackages = with pkgs; [
            jq
            bc
          ];
        };

      testScript = ''
        machine.wait_for_unit("cardano-node")
        machine.wait_for_unit("prometheus")
        machine.wait_for_unit("grafana")
        machine.wait_until_succeeds('curl --silent --fail http://127.0.0.1:12798/metrics')
        machine.wait_until_succeeds('curl --silent --fail http://127.0.0.1:3000/explore?schemaVersion=1&panes=%7B%225tr%22:%7B%22datasource%22:%22local_prometheus%22,%22queries%22:%5B%7B%22refId%22:%22A%22,%22expr%22:%22cardano_node_metrics_cardano_build_info%22,%22range%22:false,%22instant%22:true,%22datasource%22:%7B%22type%22:%22prometheus%22,%22uid%22:%22local_prometheus%22%7D,%22editorMode%22:%22builder%22,%22legendFormat%22:%22__auto%22,%22useBackend%22:false,%22disableTextWrap%22:false,%22fullMetaSearch%22:false,%22includeNullMetadata%22:true,%22format%22:%22table%22,%22exemplar%22:false%7D%5D,%22range%22:%7B%22from%22:%22now-1h%22,%22to%22:%22now%22%7D%7D%7D&orgId=1')
        print('\nVM Test Succeeded.')
      '';
    };
  };
}
