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

        testScript = ''
          # FIXME: check for cardano cli, not git
          machine.succeed("git --version")
        '';
      };
    };
  };
}
