{
  nixosTests.tests.cardano-cli.module = {
    name = "cardano-cli";
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
}
