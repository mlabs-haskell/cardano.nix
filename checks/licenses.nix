{
  perSystem = {pkgs, ...}: {
    checks = {
      reuse =
        pkgs.runCommandLocal "reuse-lint" {
          buildInputs = [pkgs.reuse];
        } ''
          cd ${../.}
          reuse lint
          touch $out
        '';
    };
  };
}
