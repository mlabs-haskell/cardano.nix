{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages =
        let
          craneLib = inputs.crane.mkLib pkgs;
          commonArgs = {
            pname = "demeter-run-cli";
            version = "0-unstable-git-${inputs.demeter-run-cli.shortRev}";
            strictDeps = true;
            src = inputs.demeter-run-cli.outPath;
          };
          demeter-run-cli = craneLib.buildPackage (
            commonArgs
            // {
              cargoArtifacts = craneLib.buildDepsOnly commonArgs;
            }
          );
        in
        {
          inherit demeter-run-cli;
        };
    };
}
