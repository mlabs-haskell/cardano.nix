{
  config,
  inputs,
  self,
  ...
}: let
  rootConfig = config;
in {
  imports = [
    ./render.nix
  ];

  renderDocs = {
    enable = true;
    sidebarOptions = [
      {
        anchor = "cardano";
        modules = [rootConfig.flake.nixosModules.cardano];
        namespaces = ["cardano"];
      }
      {
        anchor = "cardano.cli";
        modules = [rootConfig.flake.nixosModules.cli];
        namespaces = ["cardano.cli"];
      }
      {
        anchor = "cardano.node";
        modules = [rootConfig.flake.nixosModules.node];
        namespaces = ["cardano.node"];
      }
      {
        anchor = "services.cardano-node";
        modules = [rootConfig.flake.nixosModules.node];
        namespaces = ["services.cardano-node"];
      }
      {
        anchor = "cardano.ogmios";
        modules = [rootConfig.flake.nixosModules.ogmios];
        namespaces = ["cardano.ogmios"];
      }
      {
        anchor = "services.ogmios";
        modules = [rootConfig.flake.nixosModules.ogmios];
        namespaces = ["services.ogmios"];
      }
      {
        anchor = "cardano.kupo";
        modules = [rootConfig.flake.nixosModules.kupo];
        namespaces = ["cardano.kupo"];
      }
      {
        anchor = "services.kupo";
        modules = [rootConfig.flake.nixosModules.kupo];
        namespaces = ["services.kupo"];
      }
      {
        anchor = "cardano.db-sync";
        modules = [rootConfig.flake.nixosModules.db-sync];
        namespaces = ["cardano.db-sync"];
      }
      {
        anchor = "services.cardano-db-sync";
        modules = [(rootConfig.flake.nixosModules.db-sync // {config.services.cardano-db-sync.cluster = "mainnet";})];
        namespaces = ["services.cardano-db-sync"];
      }
      {
        anchor = "cardano.http";
        modules = [rootConfig.flake.nixosModules.http];
        namespaces = ["cardano.http"];
      }
      {
        anchor = "services.http-proxy";
        modules = [rootConfig.flake.nixosModules.http];
        namespaces = ["services.http-proxy"];
      }
      {
        anchor = "cardano.blockfrost";
        modules = [rootConfig.flake.nixosModules.blockfrost];
        namespaces = ["cardano.blockfrost"];
      }
      {
        anchor = "services.blockfrost";
        modules = [rootConfig.flake.nixosModules.blockfrost];
        namespaces = ["services.blockfrost"];
      }
    ];

    # Replace `/nix/store` related paths with public urls
    fixups = [
      {
        storePath = self.outPath;
        githubUrl = "https://github.com/mlabs-haskell/cardano.nix/tree/main";
      }
      {
        storePath = inputs."cardano-node-8.7.3".outPath;
        githubUrl = "https://github.com/IntersectMBO/cardano-node/tree/master";
      }
      {
        storePath = inputs.cardano-db-sync.outPath;
        githubUrl = "https://github.com/IntersectMBO/cardano-db-sync/tree/master";
      }
      {
        storePath = inputs.blockfrost.outPath;
        githubUrl = "https://github.com/blockfrost/blockfrost-backend-ryo/tree/master";
      }
    ];
  };
}
