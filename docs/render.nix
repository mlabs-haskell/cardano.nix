{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.renderDocs;

  inherit (lib) mkOption mkEnableOption mkIf;
  inherit (lib.types) bool str listOf deferredModule submodule path;

  sidebarType = submodule {
    options = {
      anchor = mkOption {
        type = str;
        description = ''
          Text to display in TOC for this options group
        '';
      };
      modules = mkOption {
        type = listOf deferredModule;
        description = ''
          List of modules to scan/render options
        '';
      };
      namespaces = mkOption {
        type = listOf str;
        description = ''
          List of dotted attribute paths to render
        '';
      };
    };
  };
  fixupType = submodule {
    options = {
      storePath = mkOption {
        type = path;
        description = ''
          Path to be replaced
        '';
      };
      githubUrl = mkOption {
        type = str;
        description = ''
          Public URL to replace storage paths for definitions in rendered docs
        '';
      };
    };
  };
in {
  options.renderDocs = {
    enable = mkEnableOption "Document rendering";
    packageName = mkOption {
      type = str;
      default = "docs";
      description = ''
        Name of package with generated documentation (in flake outputs)
      '';
    };

    sidebarOptions = mkOption {
      type = listOf sidebarType;
      default = [];
      description = ''
        List of reference sections
      '';
    };

    fixups = mkOption {
      type = listOf fixupType;
      default = [];
    };

    invisible = mkOption {
      type = bool;
      default = false;
      description = ''
        render invisible options as well
      '';
    };
  };

  config = mkIf cfg.enable {
    perSystem = {
      config,
      lib,
      pkgs,
      ...
    }: let
      inherit (pkgs) stdenv mkdocs python310Packages;

      my-mkdocs =
        pkgs.runCommand "my-mkdocs"
        {
          buildInputs = [
            mkdocs
            python310Packages.mkdocs-material
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
        cfg.sidebarOptions);

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
        find $out -type f | xargs -n1 sed -i ${lib.concatMapStrings (x: " -e 's,${x.storePath},${x.githubUrl},g'") cfg.fixups} -e "s,file://https://,https://,g"
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
      packages.${cfg.packageName} = stdenv.mkDerivation {
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

        passthru.serve = pkgs.writeShellScriptBin "serve" ''
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
            command = "nix run .#${cfg.packageName}.serve";
          }
          {
            inherit category;
            name = "docs-build";
            help = "build documentation";
            command = "nix build .#${cfg.packageName}";
          }
        ];
        packages = [
          my-mkdocs
        ];
      };
    };
  };
}
