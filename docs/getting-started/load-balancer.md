`cardano.nix` provides the [`cardano.http`](../reference/module-options/cardano.http.md) and [`services.http-proxy`](../reference/module-options/services.http-proxy.md) NixOS modules, which implement a HTTP Load Balancing Reverse Proxy and TLS Endpoint using the [`nginx`](https://nginx.org/en/) HTTP server.

Our focus here is to facilitate robust, secure, and efficient HTTP traffic management for Cardano services through load balancing and TLS termination.

## Overview

The Load Balancing Reverse Proxy and TLS Endpoint module is designed to handle HTTP requests by distributing them across multiple backend servers, ensuring optimal resource utilization and high availability. It also manages TLS termination, securing the communication between clients and the proxy.

Key features of this module include:

- **Reverse Proxy**: Act as an intermediary for requests from clients seeking resources from backend servers.
- **Load Balancing**: Distribute incoming HTTP requests across multiple backend servers to balance the load, enhance performance, and provide redundancy.
- **TLS Termination**: Manage SSL/TLS certificates with Let's Enctypt ACME and handle encryption/decryption at the proxy level.
- **Integration with Cardano Services**: Define default forwarded services for backend services included in `cardano.nix`.

See documentation for the [`cardano.http`](../reference/module-options/cardano.http.md) and [`services.http-proxy`](../reference/module-options/services.http-proxy.md) NixOS modules.

## Flake template with load balancer

An easy way to get started is to use the [flake template](https://zero-to-nix.com/concepts/flakes#templates) provided by this project. Before starting, follow the [installation instructions](installation.md). Here's how to start a new project using the template:

```
mkdir myproject
cd myproject
nix flake init --template github:mlabs-haskell/cardano.nix#cluster
git init
git add .
```

### Run virtual machines

The template provides virtual machine configurations for three nodes and a load balancer. The NixOS test framework is used to start the virtual machines and set up networking. Run all the VMs:

`nix run .#vms`

The services will be available on ports forwarded from localhost: ogmios at http://localhost:8001 and kupo at http://localhost:8002 . Grafana is available at http://localhost:8008 .

Press `Ctrl+C` to stop the machines.

## Further reading

Check out the following documentation:

[`cardano.http` NixOS module documentation](../reference/module-options/cardano.http.md)

[`services.http-proxy` NixOS module documentation](../reference/module-options/services.http-proxy.md)

[NixOS options](https://search.nixos.org/options) such as `services.nginx`, `networking.firewall`.
