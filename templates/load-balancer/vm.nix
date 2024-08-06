{modulesPath, ...}: {
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # WARNING: don't use this in production
  # Allow root login without password, auto login
  users.users.root.password = "";
  services.getty.autologinUser = "root";

  virtualisation = {
    cores = 2;
    memorySize = 2048;
    diskSize = 100 * 1024;
  };
}
