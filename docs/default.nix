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
      # FIXME: ogmios' fails with mysterious error
      #{
      #  anchor = "services.ogmios";
      #  modules = [ rootConfig.flake.nixosModules.ogmios ];
      #  namespaces = ["services.ogmios"];
      #}
      {
        anchor = "service.http-proxy";
        modules = [rootConfig.flake.nixosModules.http];
        namespaces = ["services.http-proxy"];
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
    ];
  };
}
