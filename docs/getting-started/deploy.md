## Deploy Cardano services

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

This machine is set up just like the one in [Run a VM](../vm), but can be customized.

### Look around

The file named `flake.nix` includes:

- a [https://zero-to-nix.com/concepts/nixos#configuration](NixOS configuration) to run cardano services, under `nixosConfigurations.server`
- an app to run the virtual machine as above, under `apps.x86_64-linux.vm`

The file `configuration.nix` is the configuration for the machine.

### Customize

To learn more, browse available [NixOS options in nixpkgs](https://search.nixos.org/options) and [NixOS options provided by cardano.nix](https://mlabs-haskell.github.io/cardano.nix/reference/module-options/cardano/) (see other modules in the menu on the left).

Add these options to `configuration.nix` to

###
