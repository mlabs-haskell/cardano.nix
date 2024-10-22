{
  perSystem.vmTests.tests.monitoring = {
    impure = true;
    module = {
      nodes.machine = {pkgs, ...}: {
        cardano = {
          network = "preview";
          node.enable = true;
          monitoring.enable = true;
        };

        environment.systemPackages = with pkgs; [jq bc];
      };

      testScript = ''
        machine.wait_for_unit("cardano-node")
        # TODO
        machine.succeed("false")
        print('\nVM Test Succeeded.')
      '';
    };
  };
}
