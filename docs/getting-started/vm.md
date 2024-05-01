This project provides a virtual machine configuration with all cardano services.

`nix run github:mlabs-haskell/cardano.nix#vm-preview`

A virtual machine will be started with the following services, and the following ports forwarded from the host to the VM.

| Service      | Port |
| ------------ | ---- |
| cardano-node | 3001 |
| ogmios       | 1337 |

You can log in with user `root`. The password is empty. In the virtual machine, `cardano-cli` is available to query the node.

`cardano-cli query tip --testnet-magic 2`
