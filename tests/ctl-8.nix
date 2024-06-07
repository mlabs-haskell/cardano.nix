{self, ...}: {
  perSystem.vmTests.tests.ctl-8 = {
    impure = true;
    module = {
      nodes .machine = {pkgs, ...}: {
        # use packages compatible with cardano-transaction-lib 8.0.0
        nixpkgs.overlays = [self.overlays.ctl-8];

        cardano = {
          network = "preview";
          cli.enable = true;
          node.enable = true;
          ogmios.enable = true;
          kupo.enable = true;
        };

        environment.systemPackages = with pkgs; [jq bc curl];
      };

      testScript = {nodes, ...}: let
        magic = toString nodes.machine.config.cardano.networkNumber;
      in ''
        machine.wait_for_unit("cardano-node")
        machine.wait_for_unit("cardano-node-socket")
        machine.wait_until_succeeds("""[[ $(echo "$(cardano-cli query tip --testnet-magic ${magic} | jq '.syncProgress' --raw-output) > 0.001" | bc) == "1" ]]""")
        machine.wait_for_unit("ogmios")
        machine.succeed("curl --silent --fail http://localhost:1337/health")
        machine.wait_for_unit("kupo")
        machine.succeed("curl --silent --fail http://localhost:1442/health")
        machine.wait_until_succeeds("""[[ $(echo "$(curl --silent --fail http://localhost:1337/health | jq '.networkSynchronization' --raw-output) > 0.00001" | bc) == "1" ]]""")
      '';
    };
  };
}
