{pkgs, ...}: {
  cardanoNix.tests = {
    block-producer = {
      systems = ["x86_64-linux"];

      module = {
        name = "block producer starts";

        nodes = {
          machine = {...}: {
            imports = [./block-producer-keys];
            virtualisation = {
              cores = 2;
              memorySize = 1024;
              writableStore = false;
            };
            cardanoNix.cardano-cli.enable = true;
            cardanoNix.cardano-node = {
              producer = {
                enable = true;
                relayAddrs = [
                  {
                    address = "127.0.0.1";
                    port = 3000;
                  }
                ];
              };
            };
          };
        };

        testScript = ''
          machine.wait_for_unit("cardano-node-producer.service")
          # FIXME: is oneshot, why orchestrating doesn't starts?
          # machine.wait_for_unit("cardano-node.service")
          machine.wait_for_open_port(12798) # prometheus
          machine.wait_for_open_port(3001)  # node
          machine.succeed("stat /run/cardano-node")
          machine.succeed("stat /run/cardano-node/node.socket")
          machine.succeed("systemctl status cardano-node")
          machine.succeed(
            "cardano-cli ping -h 127.0.0.1 -c 1 --magic 1 -q --json \
              | ${pkgs.jq}/bin/jq '.pongs != null' \
              | grep -e '^true$'"
          )
        '';
        # ${jq}/bin/jq -c"
      };
    };
  };
}
