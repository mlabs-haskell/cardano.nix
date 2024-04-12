{
  perSystem.vmTests.tests.cardano-db-sync = {
    impure = true;
    module = {
      nodes.machine = {pkgs, ...}: {
        cardano = {
          network = "preview";
          cli.enable = true;
          node.enable = true;
          cardano-db-sync.enable = true;
        };
        environment.systemPackages = with pkgs; [jq bc curl postgresql];
      };

      testScript = _:
      # let
      # cfg = nodes.machine;
      # dbname = cfg.cardano.cardano-db-sync.postgres.database;
      # host = "localhost";
      # sql = ''
      #   select
      #     100 * (extract (epoch from (max (time) at time zone 'UTC')) - extract (epoch from (min (time) at time zone 'UTC')))
      #         / (extract (epoch from (now () at time zone 'UTC')) - extract (epoch from (min (time) at time zone 'UTC')))
      #     as sync_percent
      #     from block ;
      #     sync_percent
      # '';
      # print(machine.succeed("systemd-analyze security cardano-db-sync"))
      # print(machine.succeed("""psql --no-password -h '${host}' -U '${dbname}' -d '${dbname}' -c '${sql}' <<< '*\n' """))
      # in
      ''
        machine.wait_for_unit("cardano-db-sync")

        print(machine.execute("pwd"))
        print(machine.execute("ls /var/lib"))
        print(machine.execute("users"))
        print(machine.execute("cat /etc/passwd"))
      '';
    };
  };
}
