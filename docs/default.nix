{
  config,
  inputs,
  self,
  ...
}: let
  rootConfig = config;
in {
  perSystem = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (pkgs) stdenv python311Packages;

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

    my-mkdocs = let
      inherit (python311Packages) mkdocs;
    in
      pkgs.runCommand "my-mkdocs"
      {
        buildInputs = [
          mkdocs
          python311Packages.mkdocs-material
        ];
      } ''
        mkdir -p $out/bin

        cat <<MKDOCS > $out/bin/mkdocs
        #!${pkgs.bash}/bin/bash
        set -euo pipefail
        export PYTHONPATH=$PYTHONPATH
        exec ${mkdocs}/bin/mkdocs "\$@"
        MKDOCS

        chmod +x $out/bin/mkdocs
      '';

    eachOptionsDoc = builtins.listToAttrs (builtins.map (
        {
          anchor,
          modules,
          namespaces,
          ...
        }:
          lib.nameValuePair
          anchor
          (pkgs.nixosOptionsDoc {
            # By default `nixosOptionsDoc` will ignore internal options but we want to show them
            # This hack will make all the options not internal and visible and optionally append to the
            # description a new field which is then corrected rendered as it was a native field
            transformOptions = opt:
              opt
              // {
                internal = false;
                visible = true;
                description = let
                  description =
                    if opt.description == null
                    then lib.debug.traceVal "FIXME: ${opt.name} have no description"
                    else opt.description;
                in ''
                  ${description}
                  ${lib.optionalString opt.internal "*Internal:* true"}
                '';
              };
            options = let
              evaluated = lib.evalModules {
                modules = (import "${inputs.nixpkgs}/nixos/modules/module-list.nix") ++ modules;
                specialArgs = {inherit pkgs;};
              };
            in
              lib.foldr (path: acc: lib.recursiveUpdate acc (lib.attrByPath (lib.splitString "." path) {} evaluated.options)) {} namespaces;
          })
      )
      sidebarOptions);

    statements =
      lib.concatStringsSep "\n"
      (lib.mapAttrsToList (n: v: ''
          path=$out/${n}.md
          cat ${v.optionsCommonMark} >> $path
        '')
        eachOptionsDoc);

    options-doc = pkgs.runCommand "nixos-options" {} ''
      mkdir $out
      ${statements}
      # Replace `/nix/store` related paths with public urls
      find $out -type f | xargs -n1 sed -i ${lib.concatMapStrings (x: " -e 's,${x.storePath},${x.githubUrl},g'") fixups} -e "s,file://https://,https://,g"
    '';

    docsPath = "./docs/reference/module-options";

    index = {
      nav = [
        {
          "Reference" = [{"NixOS Module Options" = lib.mapAttrsToList (n: _: "reference/module-options/${n}.md") eachOptionsDoc;}];
        }
      ];
    };

    indexYAML =
      pkgs.runCommand "index.yaml" {
        nativeBuildInputs = [pkgs.yq-go];
        index = builtins.toFile "index.json" (builtins.unsafeDiscardStringContext (builtins.toJSON index));
      } ''
        yq -o yaml $index >$out
      '';

    mergedMkdocsYaml =
      pkgs.runCommand "mkdocs.yaml" {
        nativeBuildInputs = [pkgs.yq-go];
      } ''
        yq '. *+ load("${indexYAML}")' ${./mkdocs.yml} -o yaml >$out
      '';
  in {
    packages = {
      docs = stdenv.mkDerivation {
        src = ../.; # FIXME: use config.flake-root.package here
        name = "cardano-nix-docs";

        nativeBuildInputs = [my-mkdocs];

        buildPhase = ''
          ln -s ${options-doc} ${docsPath}
          # mkdocs expect mkdocs one level upper than `docs/`, but we want to keep it in `docs/`
          cp ${mergedMkdocsYaml} mkdocs.yml
          mkdocs build -f mkdocs.yml -d site
        '';

        installPhase = ''
          mv site $out
          rm $out/default.nix  # Clean nwanted side-effect of mkdocs
        '';

        passthru.serve = config.packages.docs-serve;
      };

      docs-serve = pkgs.writeShellScriptBin "docs-serve" ''
        set -euo pipefail

        # link in options reference
        rm -f ${docsPath}
        ln -s ${options-doc} ${docsPath}
        rm -f mkdocs.yml
        ln -s ${mergedMkdocsYaml} mkdocs.yml

        BASEDIR="$(${lib.getExe config.flake-root.package})"
        cd $BASEDIR

        cat <<EOF
        NOTE: Documentation/index autogenerated from NixOS options doesn't reload automatically
        NOTE: Please restart 'docs-serve' for it
        EOF
        ${my-mkdocs}/bin/mkdocs serve
      '';
    };

    devshells.default = {
      commands = let
        category = "documentation";
      in [
        {
          inherit category;
          name = "docs-serve";
          help = "serve documentation web page";
          command = "nix run .#docs-serve";
        }
        {
          inherit category;
          name = "docs-build";
          help = "build documentation";
          command = "nix build .#docs";
        }
      ];
      packages = [
        my-mkdocs
      ];
    };
  };
}
