Development is supported on linux systems. Virtual machines are run with `qemu` so `kvm` is recommended. Follow the [installation guide](https://mlabs-haskell.github.io/cardano.nix/getting-started/installation/) to set up nix.

## Development Shell

`cardano.nix` provides a devshell that includes various tools to build, test, run and update the project:

```
$ nix develop
...
❄️ Welcome to the cardano.nix devshell ❄️

[documentation]

  docs-build              - build documentation
  docs-serve              - serve documentation web page

[examples]

  vm-preview              - Start vm with cardano services on the preview network and ports forwarded to host

[general commands]

  menu                    - prints this menu

[tests]

  build-all               - build all packages and checks with `devour-flake`
  check                   - run `nix flake check`
  run-vm-test             - list and run virtual machine integration tests

[tools]

  fmt                     - format the source tree
  update-git-hooks        - update git hooks
```

A `.envrc` file is also provided, using [direnv](https://direnv.net/) and [nix-direnv](https://github.com/nix-community/nix-direnv) is suggested.

### Running Integration Tests

From the devshell you can run integration tests with `run-vm-test`, for example the following will start `cardano-node` and `ogmios` on the `preview` testnet and will check for synchronization progress.

```
run-vm-test ogmios
```
