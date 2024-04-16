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

      testScript = {nodes, ...}: let
        cfg = nodes.machine;
        dbname = cfg.cardano.cardano-db-sync.postgres.database;
        inherit (cfg.services.cardano-db-sync.postgres) socketdir;
        # get sync percentage, return true if it's above 0.000001
        sql = "select (100 * (extract (epoch from (max (time) at time zone 'UTC')) - extract (epoch from (min (time) at time zone 'UTC'))) / (extract (epoch from (now () at time zone 'UTC')) - extract (epoch from (min (time) at time zone 'UTC')))) > 0.000001 from block limit 1;";
        output = "?column?\\n----------\\nt\\n(1 row)"; # postgres "true" result
      in ''
        machine.wait_for_unit("cardano-db-sync")
        machine.wait_until_succeeds(r"""[[ $(sudo -u postgres psql --no-password "host=${socketdir} user=postgres dbname=${dbname}" -c "${sql}") = "${output}" ]] """, 150)
      '';
    };
  };
}
