{
  modulesPath,
  lib,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # WARNING: don't use this in production
  # Allow root login without password
  users.users.root.hashedPasswordFile = lib.mkOverride 150 "${pkgs.writeText "hashed-password.root" ""}";

  virtualisation = {
    cores = 2;
    memorySize = 2048;
    diskSize = 100 * 1024;
  };
}
