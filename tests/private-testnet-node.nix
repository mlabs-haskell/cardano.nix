{
  perSystem.vmTests.tests.node = {
    impure = false;
    module = {
      nodes.machine =
        { pkgs, ... }:
        {
          cardano = {
            cli.enable = true;
            private-testnet-node.enable = true;
            private-testnet-node.initialFunds = {
              addr_test1vzrv7az4xq620y20pyn44yhvl89r7nwa7ga5ftn9rleenxqharu33 = [
                2000000
                3000000
              ];
              addr_test1vr6ue2hmlnj8pzzqy7353lv3yj8xu7m24pgpctv7z3qhv8c3qdt46 = 1500000;
            };
          };

          environment.systemPackages = with pkgs; [
            jq
            bc
          ];
        };

      testScript =
        { nodes, ... }:
        let
          magic = toString nodes.machine.config.cardano.networkNumber;
        in
        ''
          machine.wait_for_unit("cardano-node")

          # Check the test-node is working and syncing properly
          machine.wait_until_succeeds("""[[ $(echo "$(cardano-cli query tip --testnet-magic ${magic} | jq '.syncProgress' --raw-output) > 0.001" | bc) == "1" ]]""", 10)

          # Check that the FAUCET address has a decent amount of ADA
          # (note that because we have a non-zero amount of initial funds, some
          # will be drained from the FAUCET initially)
          machine.succeed("""
            test \
                "$(cardano-cli query utxo --output-json --address "$FAUCET" \
                    | jq --arg faucet "$FAUCET" '.[] | (.address == $faucet and .value.lovelace >= 100000000000)')" \
                = \
                true
          """)

          # Verify that the initial funds have been correctly distributed.
          machine.wait_for_unit("test-cardano-node-initial-funds")
          machine.succeed("""
            test \
                "$(cardano-cli query utxo --output-json --address addr_test1vzrv7az4xq620y20pyn44yhvl89r7nwa7ga5ftn9rleenxqharu33 \
                        | jq 'to_entries | map(.value.value)  | sort | . == [ {"lovelace" : 2000000}, {"lovelace" : 3000000} ]')" \
                = \
                true
          """)
          machine.succeed("""
            test \
                "$(cardano-cli query utxo --output-json --address addr_test1vr6ue2hmlnj8pzzqy7353lv3yj8xu7m24pgpctv7z3qhv8c3qdt46 \
                        | jq 'to_entries | map(.value.value)  | sort | . == [ {"lovelace" : 1500000} ]')" \
                = \
                true
          """)

          # Verify that we can actually use the FAUCET to give ADA out
          machine.succeed("""
            request-from-faucet --address addr_test1vq64jjlez93yz57ytlwtwsfz73n3elpty7e0w3z8l6yv3agc0e6jz --amount 10000000
          """)
          machine.succeed("""
            test \
                "$(cardano-cli query utxo --output-json --address addr_test1vq64jjlez93yz57ytlwtwsfz73n3elpty7e0w3z8l6yv3agc0e6jz \
                        | jq '.[] | (.value.lovelace >= 10000000)')" \
                = \
                true
          """)

          print(machine.succeed("systemd-analyze security cardano-node"))
          print('\nVM Test Succeeded.')
        '';
    };
  };
}
