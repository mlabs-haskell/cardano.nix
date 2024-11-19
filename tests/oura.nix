{
  perSystem.vmTests.tests.oura = {
    impure = true;
    module = {
      nodes.machine =
        { pkgs, ... }:
        {
          cardano = {
            network = "preview";
            cli.enable = true;
            node.enable = true;
            oura.enable = true;
            oura.integrate = true;
          };

          # Suppress excessive output from cardano-node,
          # we assume that node works as it's ensured by other tests
          services.cardano-node.extraServiceConfig = _: {
            serviceConfig = {
              StandardOutput = "null";
              StandardError = "null";
            };
          };
          services.oura.settings = {
            sink = {
              type = "Logs";
              output_path = "/var/log/oura/oura.jsonl";
              output_format = "JSONL";
              max_bytes_per_file = 1000000;
              max_total_files = 10;
              compress_files = false;
            };
          };
          # Writeable place for a "testing log file"
          systemd.tmpfiles.rules = [ "d /var/log/oura 755 oura oura" ];
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
          import json
          machine.wait_for_unit("cardano-node")
          machine.wait_for_unit("cardano-node-socket")
          machine.wait_until_succeeds("""[[ $(echo "$(cardano-cli query tip --testnet-magic ${magic} | jq '.syncProgress' --raw-output) > 0.001" | bc) == "1" ]]""")
          machine.wait_for_unit("oura")
          lines = machine.succeed("tail /var/log/oura/oura.jsonl")
          print(lines)
          # Ensure that block/slot numbers monotonicaly grow
          block_max = 0
          slot_max = 0
          for each in lines.strip().split("\n"):
              each = each.strip()
              js = json.loads(each)
              # Very first record haven't block record
              if not 'block' in js:
                  continue
              slot = int(js["block"]["slot"])
              block = int(js["context"]["slot"])
              assert block > block_max
              assert slot > slot_max
              block_max, slot_max = block, slot
          # Ensure that we seen few blocks
          assert block_max > 0
          assert slot_max > 0

          print(machine.succeed("systemd-analyze security oura"))
        '';
    };
  };
}
