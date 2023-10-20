{
  systems = ["x86_64-linux"];

  module = _: {
    name = "cli-test";

    nodes = {
      machine = {
        virtualisation = {
          cores = 2;
          memorySize = 1024;
          writableStore = true;
        };
        cardano-ecosystem.cli.enable = true;
      };
    };
    testScript = ''
      # FIXME: check for cardano cli, not git
      machine.succeed("git --version")
    '';
  };
}
