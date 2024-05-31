{
  perSystem.vmTests.tests.blockfrost = {
    impure = true;
    module = {
      nodes .machine = {pkgs, ...}: {
        cardano = {
          network = "preview";
          cli.enable = true;
          node.enable = true;
          db-sync.enable = true;
          blockfrost.enable = true;
        };

        environment.systemPackages = with pkgs; [jq bc curl];
      };

      testScript = {nodes, ...}: let
        magic = toString nodes.machine.config.cardano.networkNumber;
      in ''
        machine.wait_for_unit("cardano-node")
        machine.wait_for_unit("cardano-node-socket")
        machine.wait_until_succeeds("""[[ $(echo "$(cardano-cli query tip --testnet-magic ${magic} | jq '.syncProgress' --raw-output) > 0.001" | bc) == "1" ]]""")
        machine.wait_for_unit("blockfrost-backend-ryo")
        machine.wait_until_succeeds("curl http://localhost:3000", timeout=60)
        # print(machine.succeed("systemd-analyze security blockfrost"))
      '';
    };
  };
}
