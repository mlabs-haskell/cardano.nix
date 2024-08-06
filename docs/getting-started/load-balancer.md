`cardano.nix` provides the `cardano.http` and `services.http-proxy` NixOS modules, which implement a HTTP Load Balancing Reverse Proxy and TLS Endpoint using the [`nginx`](https://nginx.org/en/) HTTP server software package.

Our focus here is to facilitate robust, secure, and efficient HTTP traffic management for Cardano services through load balancing and TLS termination.

### Overview

The Load Balancing Reverse Proxy and TLS Endpoint module is designed to handle HTTP requests by distributing them across multiple backend servers, ensuring optimal resource utilization and high availability. It also manages TLS termination, securing the communication between clients and the proxy.

Key features of this module include:

- **Reverse Proxy**: Act as an intermediary for requests from clients seeking resources from backend servers.
- **Load Balancing**: Distribute incoming HTTP requests across multiple backend servers to balance the load, enhance performance, and provide redundancy.
- **TLS Termination**: Manage SSL/TLS certificates with Let's Enctypt ACME and handle encryption/decryption at the proxy level.
- **Integration with Cardano Services**: Define default forwarded services for backend services included in `cardano.nix`.

### Flake template with load balancer

Before starting, follow the [installation instructions](installation.md).

An easy way to get started is to use the [flake template](https://zero-to-nix.com/concepts/flakes#templates) provided by this project. Here's how to start a new project using the template:

```
mkdir myproject
cd myproject
nix flake init --template github:mlabs-haskell/cardano.nix
git init
git add .
```

#### Configure networking

TODO

#### Run virtual machines

The template provides virtual machine configurations for three cardano nodes and a load balancer.Run all the VMs:

`nix run .#vms`

The virtual machines are started and accessible via TODO.
