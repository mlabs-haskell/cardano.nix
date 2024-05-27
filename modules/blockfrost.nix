{
  config,
  lib,
  ...
}: let
  cfg = config.cardano.blockfrost;
  dbsync-cfg = config.services.cardano-db-sync;
  inherit (lib) mkIf mkMerge mkEnableOption;
in {
  options.cardano.blockfrost =
    {
      enable =
        mkEnableOption ''
        '';
    }
    // {default = config.cardano.enable or false;};

  config = mkIf cfg.enable (mkMerge [
    {
      services.blockfrost = {
        enable = true;
        settings = {
          inherit (config.cardano) network;
          server.debug = true;
          dbSync = {
            inherit (dbsync-cfg.postgres) user port database;
          };
        };
      };
    }
    (mkIf (config.cardano.node.enable or false) {
      systemd.services.blockfrost-backend-ryo = {
        after = ["cardano-node-socket.service"];
        requires = ["cardano-node-socket.service"];
      };
    })
    (mkIf (config.cardano.db-sync.enable or false) {
      systemd.services.blockfrost-backend-ryo = {
        after = ["cardano-db-sync.service"];
        requires = ["cardano-db-sync.service"];
      };
    })
  ]);
}
