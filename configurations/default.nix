{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = {
    vm-preview = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.default
        ./preview.nix
        ./vm.nix
        {nixpkgs.hostPlatform = "x86_64-linux";}
      ];
    };
  };
  perSystem = _: {
    apps = {
      vm-preview = {
        type = "app";
        program = "${self.nixosConfigurations.vm-preview.config.system.build.vm}/bin/run-nixos-vm";
      };
    };
  };
}
