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

### Read the [Documentation](https://mlabs-haskell.github.io/cardano.nix/)

### Development

Development is supported on linux systems. Virtual machines are run with `qemu` so `kvm` is recommended. Follow the [installation guide](https://mlabs-haskell.github.io/cardano.nix/getting-started/installation/) to set up nix.

`cardano.nix` provides a devshell that includes various tools to build, test, run and update the project:

```
❯ nix develop
...
❄️ Welcome to the cardano.nix devshell ❄️

[documentation]

  docs-build              - build documentation
  docs-serve              - serve documentation web page

[general commands]

  menu                    - prints this menu

[tests]

  build-all               - build all packages and checks with `devour-flake`
  check                   - run `nix flake check`
  run-vm-test             - list and run virtual machine integration tests

[tools]

  fmt                     - format the source tree
  update-pre-commit-hooks - update git pre-commit hooks
```

A `.envrc` file is also provided, using [direnv](https://direnv.net/) and [nix-direnv](https://github.com/nix-community/nix-direnv) is suggested.

### Running Integration Tests

From the devshell you can run integration tests with `run-vm-test`, for example the following will start `cardano-node` and `ogmios` on the `preview` testnet and will check for synchronization progress.

```
run-vm-test ogmios
```

## License information

`cardano.nix` released under terms of [Apache-2.0](LICENSES/Apache-2.0.txt) license.
