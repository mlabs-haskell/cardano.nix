`cardano.nix` provides the [`cardano.http`](../reference/module-options/cardano.http/) and [`services.http-proxy`](../reference/module-options/services.http-proxy/) NixOS modules, which implement a HTTP Load Balancing Reverse Proxy and TLS Endpoint using the [`nginx`](https://nginx.org/en/) HTTP server.

Our focus here is to facilitate robust, secure, and efficient HTTP traffic management for Cardano services through load balancing and TLS termination.

## Overview

The Load Balancing Reverse Proxy and TLS Endpoint module is designed to handle HTTP requests by distributing them across multiple backend servers, ensuring optimal resource utilization and high availability. It also manages TLS termination, securing the communication between clients and the proxy.

Key features of this module include:

- **Reverse Proxy**: Act as an intermediary for requests from clients seeking resources from backend servers.
- **Load Balancing**: Distribute incoming HTTP requests across multiple backend servers to balance the load, enhance performance, and provide redundancy.
- **TLS Termination**: Manage SSL/TLS certificates with Let's Enctypt ACME and handle encryption/decryption at the proxy level.
- **Integration with Cardano Services**: Define default forwarded services for backend services included in `cardano.nix`.

See documentation for the [`cardano.http`](../reference/module-options/cardano.http/) and [`services.http-proxy`](../reference/module-options/services.http-proxy/) NixOS modules.

## Flake template with load balancer

An easy way to get started is to use the [flake template](https://zero-to-nix.com/concepts/flakes#templates) provided by this project. Before starting, follow the [installation instructions](installation.md). Here's how to start a new project using the template:

```
mkdir myproject
cd myproject
nix flake init --template github:mlabs-haskell/cardano.nix
git init
git add .
```

### Run virtual machines

The template provides virtual machine configurations for three nodes and a load balancer. The NixOS test framework is used to start the virtual machines and set up networking. Run all the VMs:

`nix run .#vms`

The services will be available on ports forwarded from localhost: ogmios at http://localhost:8001 and kupo at http://localhost:8002 .

Press `Ctrl+C` to stop the machines.

## Deploy to the Cloud

To deploy the network of nodes and proxy to cloud providers such as AWS, Google Cloud, DigitalOcean, or Hetzner, some additional setup is required that is out of scope for this project as it depends on the deployment workflow. Here is an overview:

### Deploy Cloud Infrastructure

Cloud resources need to be created, for example with an Infrastructure-as-Code tool such as AWS CloudFormation or [OpenTofu](https://opentofu.org/).

#### Cloud Machines

Virtual machines (AWS EC2, droplet, etc.) need to be created, one for each node and one for the proxy. Synchronizing the blockchain takes a long time so auto scaling is not viable without extra setup, eg. using [cardanow](https://github.com/mlabs-haskell/cardanow/) to load snapshots or using shared network storage.

#### Networking

Private networking needs to be set up between the nodes and proxy, either via the cloud provider's native support (AWS VPC, etc.) or VPN such as wireguard.

The nodes should be configured to be reachable only via the private network on which the proxy resides. This can be as simple as disabling public IPs for these machines. More complex setups have several options to configure networking, such as the services' listen addresses (`services.ogmios.host`, and similar NixOS options), OS firewall (`networking.firewall.*`) and cloud firewall (AWS security groups etc.).

#### DNS Records

To make the proxy reachable via a web address from the browser, DNS records need to be added. This is also required for HTTPS. The opinionated default is a separate subdomain for each service, this can be overridden via nginx configuration.

Example DNS records, where the proxy public IP is `12.34.56.78`:

```text
my.example.com A 12.34.56.78
ogmios.my.example.com A 12.34.56.78
kupo.my.example.com A 12.34.56.78
```

Alternatively, a wildcard record may be added for `*.my.example.com`.

### Operating System Configuration and Deployment

NixOS has to be installed on the cloud machines. If the cloud provider does not have NixOS images, this can be achieved starting from mainstream distros like Debian or Ubuntu using [nixos-infect](https://github.com/elitak/nixos-infect) from cloud-init user data. A better option is to generate cloud images, eg. using [nixos-generators]https://github.com/nix-community/nixos-generators) and start the cloud machines from those.

To deploy operating system configuration via SSH, `services.openssh` needs to be configured and `users.users.root.openssh.authorizedKeys.keys` set. Deployment can be done via `nixos-rebuild --flake . --target-host HOST` or using a [deployment app](https://github.com/nix-community/awesome-nix?tab=readme-ov-file#deployment-tools) such as [https://github.com/zhaofengli/colmena](colmena), or integrated into an infrastructure tool like [terraform-nixos](https://github.com/nix-community/terraform-nixos).

#### Node Adresses

The proxy needs to know how to reach the nodes. This is configured in `services.http-proxy.servers`. In the NixOS test environment, nodes are reachable by hostname, because static `hosts` entries are added for them automatically. This is not available in the cloud. Several options exist:

- Use IP addresses. This is the simplest solution but can be inconvenient if private IPs are automatically assigned. Example:
  `services.http-proxy.servers = [ "10.0.0.1" "10.0.0.2" "10.0.0.3" ];`
- Add `networking.hosts` entries to the proxy, possibly from the output of other tools such as OpenTofu.
- Use `mdns` for local DNS lookups by hostname.
- Use a local DNS server such as [dnsmasq](https://dnsmasq.org/doc.html), optionally with DHCP.
- Use internal DNS provided by the cloud service (AWS Route53 private hosted zone, etc.).

#### Domain Name

Once DNS records are created for the proxy as above, the domain name needs to be configured. This is also required for HTTPS.

```nix
services.http-proxy.domainName = "my.example.com";
```

The server will now respond to HTTP requests with `Hosts` header set to `my.example.com`, as well as making the services available at `ogmios.my.example.com` etc.

#### HTTPS

To serve public web pages and APIs, it is necessary to protect data integrity and confidentiality during transmission, so [HTTPS](https://en.wikipedia.org/wiki/HTTPS) needs to be enabled on the proxy. Once DNS and domain names are configured as above, this is easily achieved with the following option:

```nix
services.http-proxy.https.enable = true;
```

This will set up [Let's Encrypt ACME TLS certificates](https://letsencrypt.org/how-it-works/) on the proxy server, enable HTTPS in the nginx web server and redirect all HTTP traffic to HTTPS.

## Further reading

Check out the following documentation:

[`cardano.http` NixOS module documentation](../reference/module-options/cardano.http/)

[`services.http-proxy` NixOS module documentation](../reference/module-options/services.http-proxy/)

[NixOS options](https://search.nixos.org/options) such as `services.nginx`, `networking.firewall`.
