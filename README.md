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

This will configure `cardano-node` and `ogmios` on the `preview` network.

### Read the [Documentation](https://mlabs-haskell.github.io/cardano.nix/)

## Setup

Install nix and enable flakes, eg. with [Determinate nix installer](https://github.com/DeterminateSystems/nix-installer).

Use the project's binary cache to skip builds. Edit `/etc/nix/nix.conf` (or related settings in NixOS config) and merge the new values separated by spaces into the options:

```
substituters = ... https://cache.staging.mlabs.city/cardano-nix
trusted-public-keys = ... cardano-nix:BQ7QKgoQQAuL3Kh6pfIJ8oxrihUbUSxf6tN9SxyW608=
```

Don't edit `~/.config/nix/nix.conf` in your home directory. Don't add users to `trusted-users` because it is [insecure](https://nixos.org/manual/nix/stable/command-ref/conf-file.html?highlight=trusted-user#conf-trusted-users).

### Development Shell

Development is supported on linux systems. Virtual machines are run with `qemu` so `kvm` is recommended.

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

A `.envrc` is also provided, using [direnv]() and [nix-direnv](https://github.com/nix-community/nix-direnv) is suggested.

### Running Integration Tests

From the devshell you can run integration tests with `run-vm-test`, for example the following will start `cardano-node` and `ogmios` on the `preview` testnet and will check for synchronization progress.

```
run-vm-test ogmios
```

## License information

`cardano.nix` released under terms of [Apache-2.0](LICENSES/Apache-2.0.txt) license.
