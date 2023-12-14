{
  inputs,
  self,
  ...
}: {
  perSystem = {
    config,
    lib,
    pkgs,
    rootConfig,
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

    eachOptions = removeAttrs rootConfig.flake.nixosModules ["default"];

    eachOptionsDoc = with lib;
      mapAttrs' (
        name: value:
          nameValuePair
          # take foo.options and turn it into just foo
          (head (splitString "." name))
          # generate options doc
          (pkgs.nixosOptionsDoc {
            options =
              (evalModules {
                modules = (import "${inputs.nixpkgs}/nixos/modules/module-list.nix") ++ [value];
                specialArgs = {inherit pkgs;};
              })
              .options
              .cardanoNix;
          })
      )
      eachOptions;

    statements = with lib;
      concatStringsSep "\n"
      (mapAttrsToList (n: v: ''
          path=$out/${n}.md
          cat ${v.optionsCommonMark} >> $path
        '')
        eachOptionsDoc);
    
    githubUrl = "https://github.com/mlabs-haskell/cardano.nix/tree/master";
    
    options-doc = pkgs.runCommand "nixos-options" {} ''
      mkdir $out
      ${statements}
      # Fixing links to storage to files in github
      find $out -type f | xargs -n1 sed -i -e "s,${self.outPath},${githubUrl},g" -e "s,file://https://,https://,g"
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
    packages.docs = stdenv.mkDerivation {
      src = ../.; # FIXME: use config.flake-root.package here
      name = "cardano-nix-docs";

      buildInput = [options-doc];
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
        category = "Docs";
      in [
        {
          inherit category;
          name = "docs-serve";
          help = "Serve docs";
          command = "nix run .#docs.serve";
        }
        {
          inherit category;
          name = "docs-build";
          help = "Build docs";
          command = "nix build .#docs";
        }
      ];
      packages = [
        my-mkdocs
      ];
    };
  };
}
