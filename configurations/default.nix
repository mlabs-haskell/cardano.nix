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
    devshells.default.commands = [
      {
        name = "vm-preview";
        category = "examples";
        command = "${self.nixosConfigurations.vm-preview.config.system.build.vm}/bin/run-nixos-vm";
        help = "Start vm with cardano services on the preview network and ports forwarded to host";
      }
    ];
  };
}
