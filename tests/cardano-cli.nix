{
  cardanoNix.tests = {
    dummy = {
      systems = ["x86_64-linux"];

      module = {
        name = "cli-test";

        nodes = {
          machine = {
            virtualisation = {
              cores = 2;
              memorySize = 1024;
              writableStore = true;
            };
            cardanoNix.cardano-cli.enable = true;
          };
        };

        # TODO `git` will be replaced by `cardano-cli` (milestone 2)
        testScript = ''
          machine.succeed("cardano-cli --version")
        '';
      };
    };
  };
}
