{
  config,
  inputs,
  self,
  ...
}:
{
  imports = [
    ./render.nix
  ];

  renderDocs = {
    enable = true;
    name = "cardano-nix-docs";
    mkdocsYamlFile = ./mkdocs.yml;
    sidebarOptions = [
      {
        anchor = "cardano";
        modules = [ config.flake.nixosModules.cardano ];
        namespaces = [ "cardano" ];
      }
      {
        anchor = "cardano.cli";
        modules = [ config.flake.nixosModules.cli ];
        namespaces = [ "cardano.cli" ];
      }
      {
        anchor = "cardano.node";
        modules = [ config.flake.nixosModules.node ];
        namespaces = [ "cardano.node" ];
      }
      {
        anchor = "services.cardano-node";
        modules = [
          config.flake.nixosModules.node
          { services.cardano-node.environment = "mainnet"; }
        ];
        namespaces = [ "services.cardano-node" ];
      }
      {
        anchor = "cardano.ogmios";
        modules = [ config.flake.nixosModules.ogmios ];
        namespaces = [ "cardano.ogmios" ];
      }
      {
        anchor = "services.ogmios";
        modules = [ config.flake.nixosModules.ogmios ];
        namespaces = [ "services.ogmios" ];
      }
      {
        anchor = "cardano.kupo";
        modules = [ config.flake.nixosModules.kupo ];
        namespaces = [ "cardano.kupo" ];
      }
      {
        anchor = "services.kupo";
        modules = [ config.flake.nixosModules.kupo ];
        namespaces = [ "services.kupo" ];
      }
      {
        anchor = "cardano.db-sync";
        modules = [ config.flake.nixosModules.db-sync ];
        namespaces = [ "cardano.db-sync" ];
      }
      {
        anchor = "services.cardano-db-sync";
        modules = [ (config.flake.nixosModules.db-sync // { config.services.cardano-db-sync.cluster = "mainnet"; }) ];
        namespaces = [ "services.cardano-db-sync" ];
      }
      {
        anchor = "cardano.http";
        modules = [ config.flake.nixosModules.http ];
        namespaces = [ "cardano.http" ];
      }
      {
        anchor = "services.http-proxy";
        modules = [ config.flake.nixosModules.http ];
        namespaces = [ "services.http-proxy" ];
      }
      {
        anchor = "cardano.blockfrost";
        modules = [ config.flake.nixosModules.blockfrost ];
        namespaces = [ "cardano.blockfrost" ];
      }
      {
        anchor = "services.blockfrost";
        modules = [ config.flake.nixosModules.blockfrost ];
        namespaces = [ "services.blockfrost" ];
      }
      {
        anchor = "cardano.oura";
        modules = [ config.flake.nixosModules.oura ];
        namespaces = [ "cardano.oura" ];
      }
      {
        anchor = "services.oura";
        modules = [ config.flake.nixosModules.oura ];
        namespaces = [ "services.oura" ];
      }
    ];

    # Replace `/nix/store` related paths with public urls
    fixups = [
      {
        storePath = self.outPath;
        githubUrl = "https://github.com/mlabs-haskell/cardano.nix/tree/main";
      }
      {
        storePath = inputs.cardano-node.outPath;
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
