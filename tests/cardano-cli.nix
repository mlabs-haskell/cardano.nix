{
  perSystem.vmTests.tests.cardano-cli.module = {
    nodes.machine = {
      cardano.cli.enable = true;
    };

    testScript = ''
      machine.succeed("cardano-cli --version")
    '';
  };
}
