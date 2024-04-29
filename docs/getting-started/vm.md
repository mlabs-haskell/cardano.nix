## Run Cardano services in a Virtual Machine

This project provides a virtual machine configuration with all cardano services.

`nix run github:mlabs-haskell/cardano.nix#vm-preview`

Log in with user `root`. The password is empty.

The following services will be started and ports forwarded to the host:

|cardano-node|3001|
|ogmios|1337|

In the virtual machine, `cardano-cli` is available to query the node.

`cardano-cli query tip --testnet-magic 2`
