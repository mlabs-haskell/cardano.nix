# cardano.nix

Collection of Cardano related Nix packages and NixOS modules, with a special focus on:

- auto-generated [documentation](https://mlabs-haskell.github.io/cardano.nix/)
- virtual machine based integration [tests](tests/)
- easy to use [module interface](https://mlabs-haskell.github.io/cardano.nix/reference/module-options/cardano/)

Example:

```nix
{
  cardano = {
    network = "preview";
    node.enable = true;
    ogmios.enable = true;
  };
}
```

This NixOS configuration will start `cardano-node` and `ogmios` on the `preview` network.

### Read the [Documentation](https://mlabs-haskell.github.io/cardano.nix/)

## Quick start

[Install nix with flakes](https://github.com/DeterminateSystems/nix-installer). Run a virtual machine with cardano-node and ogmios:

```bash
nix run github:mlabs-haskell/cardano.nix#vm-preview
```

Ogmios will be available at http://localhost:1337

Read the [Documentation](https://mlabs-haskell.github.io/cardano.nix/) on how to get started and deploy cardano services on virtual or cloud machines.

## Developing cardano.nix

See the [development documentation](https://mlabs-haskell.github.io/cardano.nix/development/develop/) on how to set up binary caches to speed up builds, start the development shell, and run virtual machine network integration tests.

## License information

`cardano.nix` released under terms of [Apache-2.0](LICENSES/Apache-2.0.txt) license.
