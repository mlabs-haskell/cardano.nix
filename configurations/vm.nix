{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 4 * 1024;
    }
  ];

  # WARNING: don't use this in production
  # Allow root login without password, auto login
  users.users.root.password = "";
  services.getty.autologinUser = "root";

  virtualisation = {
    cores = 2;
    memorySize = lib.mkDefault 4096;
    diskSize = lib.mkDefault (100 * 1024);
    forwardPorts = [
      {
        # http
        from = "host";
        host.port = 8080;
        guest.port = 80;
      }
      {
        # cardano-node
        from = "host";
        host.port = 3001;
        guest.port = 3001;
      }
      {
        # ogmios
        from = "host";
        host.port = 1337;
        guest.port = 1337;
      }
      {
        # kupo
        from = "host";
        host.port = 1442;
        guest.port = 1442;
      }
    ];
  };
}
