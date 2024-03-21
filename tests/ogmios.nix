{
  perSystem.vmTests.tests.ogmios = {
    impure = true;
    module = {
      nodes = {
        machine = {pkgs, ...}: {
          virtualisation = {
            cores = 1;
            memorySize = 1024;
          };
          cardanoNix = {
            globals.network = "preview";
            cardano-cli.enable = true;
            cardano-node.enable = true;
            ogmios.enable = true;
          };

          environment.systemPackages = with pkgs; [jq bc curl];
        };
      };

      testScript = ''
        machine.wait_for_unit("cardano-node")
        machine.wait_for_unit("cardano-node-socket")
        machine.wait_until_succeeds("""[[ $(echo "$(cardano-cli query tip --testnet-magic 2 | jq '.syncProgress' --raw-output) > 0.001" | bc) == "1" ]]""")
        machine.wait_for_unit("ogmios")
        machine.succeed("curl --fail http://localhost:1337")
        machine.wait_until_succeeds(r"""journalctl --no-pager -r -n 1 -u ogmios.service -g networkSynchronization\":0\.[0-9][0-9][0-9][1-9]""")
        print(machine.succeed("systemd-analyze security ogmios"))
      '';
    };
  };
}
