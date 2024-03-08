{
  cardanoNix.tests = {
    cardano-node = {
      systems = ["x86_64-linux"];
      impure = true;

      module = {
        name = "cardano-node-test";

        nodes = {
          machine = {pkgs, ...}: {
            virtualisation = {
              cores = 1;
              memorySize = 1024;
            };
            cardanoNix = {
              globals.network = "preview";
              cardano-cli.enable = true;
              cardano-node = {
                enable = true;
              };
            };

            environment.systemPackages = with pkgs; [jq bc];
          };
        };

        testScript = ''
          machine.wait_for_unit("cardano-node")
          machine.wait_until_succeeds("""[[ $(echo "$(cardano-cli query tip --testnet-magic 2 | jq '.syncProgress' --raw-output) > 0.01" | bc) == "1" ]]""")
        '';
      };
    };
  };
}
