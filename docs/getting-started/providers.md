## Cardano Providers Module

### Introduction

The Cardano Providers module defines a common interface for services that depend on a Cardano node.
Instead of binding directly to a specific systemd unit, services interact with an abstract provider.
This indirection makes it possible to switch seamlessly between different backends
(for example, a local `cardano-node` or a remote tunnel such as Demeter)
without changing service configuration.

The module ensures that shared options and access rules are consistent across all consumers, while hiding implementation details of the underlying node.

### Design Rationale

This design has several advantages:

- **Flexibility** – a consumer does not need to know whether the node is provided locally or remotely.
- **Transparency** – switching between a local `cardano-node` and a remote tunnel (e.g., from Demeter) requires no changes on the consumer side.
- **Reusability** – common configuration options are centralized and can be shared across different providers.
- **Consistency** – consumers operate against a unified contract, regardless of the actual implementation.

### Contract and Visibility

Options under `cardano.provider.*` should be set only in respective provider implementations,
and only referenced in other services.

If a service provider is enabled, it must set `cardano.provider.$servicename.active = true`.
Consumers can check `cardano.provider.$servicename.active` for service presence and use provider values without additional checks.

### Service Integration Guidelines

All new services added under `cardano.nix` must integrate exclusively through the provider interface:

- Services must use `cardano.providers.node.socketPath` to locate the node socket.

- Services must respect `cardano.providers.node.accessGroup` for Unix group-based permissions.

- Direct references to a particular `cardano-node` systemd unit or its implementation details are forbidden.

This rule applies not only to Cardano consumers like `cardano-cli` or monitoring tools, but also to middleware services such as Ogmios, Kupo, and others.
The goal is to guarantee that any consumer can transparently switch between different backends (local node, remote tunnel, etc.) without reconfiguration.
