{
  perSystem.vmTests.tests.cardano-cli.module = {
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
