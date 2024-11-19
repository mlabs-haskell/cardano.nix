{
  perSystem.vmTests.tests.kupo = {
    impure = true;
    module = {
      nodes.machine =
        { pkgs, ... }:
        {
          cardano = {
            network = "preview";
            cli.enable = true;
            node.enable = true;
            ogmios.enable = true;
            kupo.enable = true;
          };

          environment.systemPackages = with pkgs; [
            jq
            bc
            curl
          ];
        };

      testScript =
        { nodes, ... }:
        let
          magic = toString nodes.machine.config.cardano.networkNumber;
        in
        ''
          machine.wait_for_unit("cardano-node")
          machine.wait_for_unit("cardano-node-socket")
          machine.wait_until_succeeds("""[[ $(echo "$(cardano-cli query tip --testnet-magic ${magic} | jq '.syncProgress' --raw-output) > 0.001" | bc) == "1" ]]""")
          machine.wait_for_unit("kupo")
          machine.succeed("curl --silent --fail http://localhost:1442/health")
          print(machine.succeed("systemd-analyze security kupo"))
        '';
    };
  };
}
