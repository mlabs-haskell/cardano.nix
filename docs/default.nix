{
  config,
  inputs,
  ...
}: {
  perSystem = {
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

    options-doc = let
      # FIXME: options rendering implemented to have one page per module, but temporary it squashed to single page
      # Reason -- we need to explicitly list all pages in mkdocs.yml, so it postponed for later resolution
      eachOptions = {inherit (config.flake.nixosModules) default;};

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
    in
      pkgs.runCommand "nixos-options" {} ''
        mkdir $out
        ${statements}
      '';
    docsPath = "./docs/reference/module-options";
  in {
    packages.docs = stdenv.mkDerivation {
      src = ../.; # FIXME: use config.flake-root.package here
      name = "cardano-nix-docs";

      buildInput = [options-doc];
      nativeBuildInputs = [my-mkdocs];

      buildPhase = ''
        ln -s ${options-doc} ${docsPath}
        # mkdocs expect mkdocs one level upper than `docs/`, but we want to keep it in `docs/`
        cp docs/mkdocs.yml .
        mkdocs build -f mkdocs.yml -d site
      '';

      installPhase = ''
        mv site $out
      '';

      passthru.serve = pkgs.writeShellScriptBin "serve" ''
        set -euo pipefail

        # link in options reference
        rm -f ${docsPath}
        ln -s ${options-doc} ${docsPath}

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
