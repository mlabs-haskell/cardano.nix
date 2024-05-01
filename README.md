# cardano.nix

Collection of Cardano related Nix packages and NixOS modules, with a special focus on:

- auto-generated [documentation](https://mlabs-haskell.github.io/cardano.nix/)
- virtual machine based integration [tests](tests/)
- easy to use [module interface](https://mlabs-haskell.github.io/cardano.nix/reference/module-options/cardano/)

```nix
{
  cardano = {
    enable = true;
    network = "preview";
  };
}
```

This example NixOS configuration will run `cardano-node` and related services on the `preview` network.

#### Read the [Documentation](https://mlabs-haskell.github.io/cardano.nix/)

### Development

To get started, [install nix with flakes enabled](https://zero-to-nix.com/start/install). Enter the development shell and a list of useful tools will be displayed

```bash
$ nix develop
...
❄️ Welcome to the cardano.nix devshell ❄️
...
```

See the [Development Documentation](https://mlabs-haskell.github.io/cardano.nix/development/develop/) for more information.

### Running Integration Tests

From the devshell you can run integration tests with `run-vm-test`, for example the following will start `cardano-node` and `ogmios` on the `preview` testnet and will check for synchronization progress.

```
run-vm-test ogmios
```

## License information

`cardano.nix` released under terms of [Apache-2.0](LICENSES/Apache-2.0.txt) license.
