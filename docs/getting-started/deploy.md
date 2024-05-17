In order to access all the options available in `cardano.nix`, the [NixOS module](https://zero-to-nix.com/concepts/nixos#modules) provided by this project has to be included in a [NixOS configuration](https://zero-to-nix.com/concepts/nixos#configuration) and deployed to a (local or remote or virtual) machine.

### Start new project with flake template

An easy way to get started is to use the [flake template](https://zero-to-nix.com/concepts/flakes#templates) provided by this project. Here's how to start a new project using the template:

```
mkdir myproject
cd myproject
nix flake init --template github:mlabs-haskell/cardano.nix
git init
git add .
```

### Run a virtual machine

The default template provides a virtual machine configuration starting all the services in the preview testnet. Here's how to run it:

`nix run .#vm`

This machine is set up just like the one in [Run a VM](vm.md), but can be customized.

### Look around

#### `flake.nix`

This [Nix Flake](https://zero-to-nix.com/concepts/flakes) is the entry point to the project. It locks inputs and provides the following inputs:

- a NixOS configuration for the virtual machine, under `nixosConfigurations.server-vm`
- an app to run the virtual machine as above, under `apps.x86_64-linux.server-vm`

#### `preview.nix`

This is the [NixOS configuration](https://zero-to-nix.com/concepts/nixos#configuration) to run cardano services for the machine.

#### `vm.nix`

This NixOS configuration sets virtual machine options such as cores, memory and port forwarding. It is included in the configuration for the `nixosConfigurations.server-vm` virtual machine in `flake.nix`.

### Customize

To learn more, browse available [NixOS options in nixpkgs](https://search.nixos.org/options) and [NixOS options provided by cardano.nix](../reference/module-options/cardano.md) (see other modules in the menu on the left). You can ad these options to `preview.nix` to configure the system.

### Deployment options

The configuration can be deployed to any target running NixOS, such as:

- cloud hosts on AWS, DigitalOcean or any other cloud provider
- physical machines
- [NixOS containers](https://nixos.org/manual/nixos/stable/#sec-declarative-containers)

There are a variety of resources to help install NixOS:

- the [official documentation installation guide](https://nixos.org/manual/nixos/stable/#ch-installation)
- [nixos-anywhere](https://nix-community.github.io/nixos-anywhere/quickstart.html) to deploy on existing hosts running other distrbutions
- various web resources for specific cloud providers or other circumstances

With a running NixOS installation and a NixOS configuration `server` in a nix flake, this command will deploy the server:

`nixos-rebuild switch --flake .#server --target-host <target>`
