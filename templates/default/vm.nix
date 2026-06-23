{
  config,
  lib,
  modulesPath,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # "${modulesPath}/virtualisation/qemu-vm.nix"
    # "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/virtualisation/docker-image.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
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

  services.ogmios.host = "0.0.0.0";
  services.kupo.host = "0.0.0.0";

  networking.firewall.allowedTCPPorts = [
    config.services.ogmios.port
    config.services.kupo.port
  ];


  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  services.journald.console = "/dev/console";

  system.build.tarball = lib.mkForce (pkgs.callPackage "${inputs.nixpkgs.outPath}/nixos/lib/make-system-tarball.nix" {
    compressionExtension = "";
    compressCommand = "cat";
    contents = [
      {
        source = "${config.system.build.toplevel}/.";
        target = "./";
      }
    ];
    extraArgs = "--owner=0";

    # Add init script to image
    storeContents =  map (x: {
    object = x;
    symlink = "none";
  }) [
      config.system.build.toplevel
      pkgs.stdenv
    ];

    # Some container managers like lxc need these
    extraCommands =
      let
        script = pkgs.writeScript "extra-commands.sh" ''
          rm etc
          mkdir -p proc sys dev etc
        '';
      in
      script;
  }
);

  # formatAttr = "tarball";
  # fileExtension = ".tar.xz";

  # virtualisation = {
  #   cores = 2;
  #   memorySize = lib.mkDefault 4096;
  #   diskSize = lib.mkDefault (100 * 1024);
  #   qemu.options = [ "-nographic" ];
  #   # diskImage
  #   forwardPorts = [
  #     {
  #       # http
  #       from = "host";
  #       host.port = 8080;
  #       guest.port = 80;
  #     }
  #     {
  #       # cardano-node
  #       from = "host";
  #       host.port = 3001;
  #       guest.port = 3001;
  #     }
  #     {
  #       # ogmios
  #       from = "host";
  #       host.port = 1337;
  #       guest.port = 1337;
  #     }
  #     {
  #       # kupo
  #       from = "host";
  #       host.port = 1442;
  #       guest.port = 1442;
  #     }
  #   ];
  # };
}
