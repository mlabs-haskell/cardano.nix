{
  perSystem.vmTests.tests.cardano-db-sync = {
    impure = true;
    module = {
      nodes.machine = {pkgs, ...}: {
        cardano = {
          network = "preview";
          cli.enable = true;
          node.enable = true;
          # cardano-db-sync.enable = true;
        };
        services.postgresql = {
          enable = true;
          ensureUsers = [
            {
              name = "karol";
              ensureDBOwnership = true;
            }
          ];
        };
        environment.systemPackages = with pkgs; [jq bc curl postgresql];
      };

      testScript = {nodes, ...}: let
        magic = toString nodes.machine.config.cardano.networkNumber;
      in ''
        machine.wait_for_unit("cardano-node")
        machine.wait_for_unit("cardano-node-socket")
        machine.wait_until_succeeds("""[[ $(echo "$(cardano-cli query tip --testnet-magic ${magic} | jq '.syncProgress' --raw-output) > 0.001" | bc) == "1" ]]""")
        machine.wait_for_unit("cardano-db-sync")

        print(machine.succeed("systemd-analyze security cardano-db-sync"))
      '';
    };
  };
}
