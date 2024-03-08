{
  cardanoNix.tests = {
    cardano-cli = {
      systems = ["x86_64-linux"];

      module = {
        name = "cardano-cli-test";

        nodes = {
          machine = {
            virtualisation = {
              cores = 2;
              memorySize = 1024;
            };
            cardanoNix.cardano-cli.enable = true;
          };
        };

        testScript = ''
          machine.succeed("cardano-cli --version")
        '';
      };
    };
  };
}
