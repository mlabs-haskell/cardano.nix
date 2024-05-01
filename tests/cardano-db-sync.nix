{
  perSystem.vmTests.tests.cardano-db-sync = {
    # The test runs cardano-db-sync with postgres enabled and checks that the db syncs.
    # We call the db as the `postgres` user, but the service connects as the `cdbsync` user, but it is systemd dynamic user.
    # Test runs impure to access the "preview" network.
    impure = true;
    module = {
      nodes.machine = {pkgs, ...}: {
        cardano = {
          network = "preview";
          cli.enable = true;
          node.enable = true;
          cardano-db-sync = {
            enable = true;
            postgres.enable = true;
          };
        };
        environment.systemPackages = with pkgs; [jq bc curl postgresql];
      };

      testScript = {nodes, ...}: let
        cfg = nodes.machine;
        inherit (cfg.cardano.cardano-db-sync.database) name socketdir;
        # get sync percentage, return true if it's above 0.000000001
        sql = "select (100 * (extract (epoch from (max (time) at time zone 'UTC')) - extract (epoch from (min (time) at time zone 'UTC'))) / (extract (epoch from (now () at time zone 'UTC')) - extract (epoch from (min (time) at time zone 'UTC')))) > 0.000000001 from block limit 1;";
        output = " ?column? \\n----------\\n t\\n(1 row)\\n\\n"; # postgres "true" result
      in ''
        import time
        machine.wait_for_unit("cardano-db-sync")
        i = 0
        timeout = 420
        while True:
          (status, output) = machine.execute(r"""sudo -u postgres psql --no-password "host=${socketdir} user=postgres dbname=${name}" -c "${sql}" """)
          if i >= timeout:
            print("Can't wait forever for the dbsync to reach 0.000000001. Exiting - dbsync doesn't seem to sync.")
            raise Exception("Timeout")
          elif status == 0 and output == "${output}":
            print("DbSync started syncing. Succeeds.")
            break
          i += 1
          time.sleep(3)
        print(machine.succeed("systemd-analyze security cardano-db-sync"))
      '';
    };
  };
}
