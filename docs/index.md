# About the Project

`cardano.nix` is a collection of [Nix](https://nixos.org) packages and [NixOS modules](https://zero-to-nix.com/concepts/nixos#modules) designed to make it easy to operate [Cardano](https://cardano.org) related services and infrastructure.

### Why?

[Nix](https://zero-to-nix.com/concepts/nix) is a [declarative](https://zero-to-nix.com/concepts/declarative) package manager ensuring hash-based [dependency pinning](https://zero-to-nix.com/concepts/pinning) and [reproducible](<[reproducible](https://zero-to-nix.com/concepts/reproducibility)>) builds. [NixOS](https://zero-to-nix.com/concepts/nixos) is a Linux distribution with a [declarative configuration](https://zero-to-nix.com/concepts/nixos#configuration) system providing [atomic](https://zero-to-nix.com/concepts/nixos#atomicity) updates and [rollbacks](https://zero-to-nix.com/concepts/nixos#rollbacks). These features are responsible for the increased reliability of a NixOS system, making it an attractive DevOps toolset for deploying Cardano services.

### What?

The `cardano.nix` project aims to provide [NixOS modules](https://zero-to-nix.com/concepts/nixos#modules) for Cardano services such as `cardano-node`, `ogmios`, `kupo`, `cardano-db-sync`, as well as auxiliary modules such as firewall and HTTP(S), making it easy to deploy these services in production. Very little configuration is needed to run the services with sane defaults that are easy to customize. The services can be run on the same host or in a distributed cluster, and a HTTPS proxy module is also provided.

### How?

Here are some motivating examples.

This NixOS configuration will start `cardano-node` and related services on the `preview` testnet.

```nix
{
  cardano = {
    enable = true;
    network = preview;
  };
}
```

This snippet will configure a HTTPS reverse proxy and load balancer with ACME certificates from Let's Encrypt. DNS records need to be set up and the backend servers (configured as above) need to be reachable.

```nix
{
  cardano.http.enable = true;
  services.http-proxy = {
    domainName = "preview.example.com";
    https.enable = true;
    servers = ["server1" "server2"];
  };
};
```

Configurations including the above can be deployed to a laptop, a virtual machine, a cloud instance, a container, or any other system running NixOS. Example configurations and shortcuts to run virtual machines are provided as part of the project.
