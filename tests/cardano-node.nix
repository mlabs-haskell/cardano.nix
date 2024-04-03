{
  perSystem.vmTests.tests.cardano-node = {
    impure = true;
    module = {
      nodes.machine = {pkgs, ...}: {
        cardano = {
          network = "preview";
          cli.enable = true;
          node.enable = true;
        };

        environment.systemPackages = with pkgs; [jq bc];
      };

      testScript = {nodes, ...}: let
        magic = toString nodes.machine.config.cardanoNix.globals.networkNumber;
      in ''
        machine.wait_for_unit("cardano-node")
        machine.wait_until_succeeds("""[[ $(echo "$(cardano-cli query tip --testnet-magic ${magic} | jq '.syncProgress' --raw-output) > 0.001" | bc) == "1" ]]""")
        print(machine.succeed("systemd-analyze security cardano-node"))
      '';
    };
  };
}
