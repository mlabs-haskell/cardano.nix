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
    vm-monitoring = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.default
        ./monitoring.nix
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
      vm-monitoring = {
        type = "app";
        program = "${self.nixosConfigurations.vm-monitoring.config.system.build.vm}/bin/run-nixos-vm";
      };
    };
    devshells.default.commands = [
      {
        name = "vm-preview";
        category = "examples";
        command = "${self.nixosConfigurations.vm-preview.config.system.build.vm}/bin/run-nixos-vm";
        help = "Start vm with cardano services on the preview network with ports forwarded to host";
      }
      {
        name = "vm-monitoring";
        category = "examples";
        command = "${self.nixosConfigurations.vm-monitoring.config.system.build.vm}/bin/run-nixos-vm";
        help = "Start vm with cardano services and monitoring with ports forwarded to host";
      }
    ];
  };
}
