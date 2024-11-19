{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      checks = {
        reuse =
          pkgs.runCommandLocal "reuse-lint"
            {
              buildInputs = [ pkgs.reuse ];
            }
            ''
              cd ${self}
              reuse --suppress-deprecation lint
              touch $out
            '';
      };
    };
}
