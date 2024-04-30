### Requirements

- linux
- nix
- kvm (optional, for running virtual machine tests)

## Setup

Follow [this guide](https://zero-to-nix.com/start/install) to Install nix with [flakes](https://nix.dev/concepts/flakes.html) enabled.

### Binary cache

You can optionally use this project's binary cache to skip building software and download it instead. Edit `/etc/nix/nix.conf` (or related settings in NixOS config) and merge the new values separated by spaces into the options:

```
substituters = ... https://cache.staging.mlabs.city/cardano-nix
trusted-public-keys = ... cardano-nix:BQ7QKgoQQAuL3Kh6pfIJ8oxrihUbUSxf6tN9SxyW608=
```

Don't edit `~/.config/nix/nix.conf` in your home directory. Don't add users to `trusted-users` because it is [insecure](https://nixos.org/manual/nix/stable/command-ref/conf-file.html?highlight=trusted-user#conf-trusted-users).

### Check that it works

`nix --version`

### Learn more

For an introduction to the Nix ecosystem, check out [Zero to Nix](https://zero-to-nix.com/). Learn more about [Nix flakes](https://zero-to-nix.com/concepts/flakes) and [NixOS](https://zero-to-nix.com/concepts/nixos).
