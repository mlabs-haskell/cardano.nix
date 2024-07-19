{
  perSystem.vmTests.tests.oura = {
    impure = true;
    module = {
      nodes.machine = {pkgs, ...}: {
        cardano = {
          network = "preview";
          cli.enable = true;
          node.enable = true;
          oura.enable = true;
        };

        services.oura.settings = {
          sink = {
            type = "Logs";
            output_path = "/var/log/oura";
            output_format = "JSONL";
            max_bytes_per_file = 1000000;
            max_total_files = 10;
            compress_files = false;
          };
        };
        environment.systemPackages = with pkgs; [jq bc curl];
      };

      testScript = {nodes, ...}: let
        magic = toString nodes.machine.config.cardano.networkNumber;
      in ''
        machine.wait_for_unit("cardano-node")
        machine.wait_for_unit("cardano-node-socket")
        machine.wait_until_succeeds("""[[ $(echo "$(cardano-cli query tip --testnet-magic ${magic} | jq '.syncProgress' --raw-output) > 0.001" | bc) == "1" ]]""")
        machine.wait_for_unit("oura")
        print(machine.succeed("cat ${nodes.machine.config.services.oura.configFile}"))
        print(machine.succeed("tail /var/log/oura"))
        print(machine.succeed("systemd-analyze security oura"))
      '';
    };
  };
}
