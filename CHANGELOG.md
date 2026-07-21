# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.5.0] - 2026-07-21

## <!-- 0 -->🚀 Features

- blockfrost: bump 6.4.0 -> 6.7.0
  ([abe1954](https://github.com/mlabs-haskell/cardano.nix/commit/abe1954fbb920185251381e714a1aa1862dda118)) - Alexander V. Nikolaev (2026-06-27)

- cardano-node: bump 10.7.1 -> 11.0.1
  ([2eb2665](https://github.com/mlabs-haskell/cardano.nix/commit/2eb2665cea73a2f8e59b4d5db5ed17eda0c99522)) - Alexander V. Nikolaev (2026-06-28)

- ogmios: bump 6.14.0 -> 7.0.0
  ([3d0e841](https://github.com/mlabs-haskell/cardano.nix/commit/3d0e841efb1c0db3cb3b5c5a707b14db63e32175)) - Alexander V. Nikolaev (2026-07-07)

- cardano-db-sync: bump 13.7.0.1 -> 13.7.2.1
  ([39728e3](https://github.com/mlabs-haskell/cardano.nix/commit/39728e32b90620fbc50489d095cd9f32ec55771f)) - Alexander V. Nikolaev (2026-07-07)

## <!-- 7 -->⚙️ Miscellaneous Tasks

- bump nixpkgs and treefmt-nix
  ([2327437](https://github.com/mlabs-haskell/cardano.nix/commit/23274378d60ad4fd052e14bbc25c190d06f02a26)) - Alexander V. Nikolaev (2026-06-28)

## [1.4.0] - 2026-05-14

### Features

- Update cardano-node from 10.5.3 to 10.7.1
  ([d63ef88](https://github.com/mlabs-haskell/cardano.nix/commit/d63ef8819f0aa6c0a94b7c6e0f71ece02ee9da79))

- Update cardano-db-sync from 13.6.0.6 to 13.7.0.1
  ([8f75ac2](https://github.com/mlabs-haskell/cardano.nix/commit/8f75ac27e35ae514534615364e338c42d62cb654))

- Update blockfrost from v5.0.0 to v6.4.0
  ([ee8c2d6](https://github.com/mlabs-haskell/cardano.nix/commit/ee8c2d6d6d8ca377efdf1c1e10aaaec85f9d2d8a))

- Re-export db-sync packages
  ([66a4279](https://github.com/mlabs-haskell/cardano.nix/commit/66a427901421074b799bcb0eeb411b744d967d60))

### Bug Fixes

- Fix db-sync-tool package name
  ([e3cc6ca](https://github.com/mlabs-haskell/cardano.nix/commit/e3cc6caf7cef7ddfa8e079fd6bbab1ffdff2d537))

- Add Dijkstra era genesis to private-testnet-node
  ([d253d23](https://github.com/mlabs-haskell/cardano.nix/commit/d253d23cb8a2d5db1f407509e29338f31b27866b))

## [1.3.0] - 2026-01-28

### Features

- Add `updateSystemStartTime` option to private-testnet-node
  ([02a438d](https://github.com/mlabs-haskell/cardano.nix/commit/02a438d0b412ff094f9b77ae3e148b6382629861))

- Update cardano-node from 10.5.1 to 10.5.3
  ([2fab310](https://github.com/mlabs-haskell/cardano.nix/commit/2fab310a1ec024b8a670c486c8e2034ffdfd522c))

- Update oura from 1.9.4 to 2.0.0
  ([665eb2b](https://github.com/mlabs-haskell/cardano.nix/commit/665eb2ba082050d3d183c56ce57e57913a992cf2))

- Update ogmios from 6.13.0 to 6.14.0
  ([406fc3d](https://github.com/mlabs-haskell/cardano.nix/commit/406fc3dc49f8ba47f26acd9564914c53c293fae9))

- Update cardano-db-sync from 13.6.0.5 to 13.6.0.6
  ([498e2ff](https://github.com/mlabs-haskell/cardano.nix/commit/498e2ff0764d216824dd5252fe014d48bce72207))

- Update blockfrost from 4.1.2 to 5.0.0
  ([498e2ff](https://github.com/mlabs-haskell/cardano.nix/commit/498e2ff0764d216824dd5252fe014d48bce72207))

### Bug Fixes

- Fix eval errors by bumping hercules-ci-effect
  ([d6a5810](https://github.com/mlabs-haskell/cardano.nix/commit/d6a5810f96958b758596ccc9be6dfebdf08b0a5e))

### Improvements

- Fix deprecated 'stdenv.system' warnings
  ([b53ccdc](https://github.com/mlabs-haskell/cardano.nix/commit/b53ccdc060c2631c92a65a1c1e3b87eb85cb5a16))

## [1.2.0] - 2025-09-19

### Features

- Update cardano-db-sync from 13.6.0.2 to 13.6.0.5
  ([182c65e](https://github.com/mlabs-haskell/cardano.nix/commit/182c65edc8f2ebd8195d1723ab851e3a9c68a7bd))

- Update ogmios from 6.8.0 to 6.13.0
  ([0a2658a](https://github.com/mlabs-haskell/cardano.nix/commit/0a2658a829ea390a42fd86b010f778b2d6620ede))

- Update cardano-node from 10.4.1 to 10.5.1
  ([ad56d64](https://github.com/mlabs-haskell/cardano.nix/commit/ad56d644ea0273965483c605d91c2e8ad98bd19f))

### Bug Fixes

- Use PraosMode as default consensus mode for cardano-node
  ([1ee34ff](https://github.com/mlabs-haskell/cardano.nix/commit/1ee34ff79eac80570851a0f4fb31724d9a7c93f0))

### Documentation

- Add release management guide
  ([0b5f9c1](https://github.com/mlabs-haskell/cardano.nix/commit/0b5f9c12280139be9db5d9a17c83d460a4e1591c))

### Improvements

- Move flake-parts definition to templates
  ([4c12871](https://github.com/mlabs-haskell/cardano.nix/commit/4c128713668c8c9e409529425f4e909cd8e6e854))

- Format code using latest nixfmt
  ([b2bfa00](https://github.com/mlabs-haskell/cardano.nix/commit/b2bfa007e905dbb749ec794e80d1578d49b40f09))

- Update flake inputs and reduce transitive dependencies
  ([3c73703](https://github.com/mlabs-haskell/cardano.nix/commit/3c737030879adec3e3bf452d7bd7432a885a5c49))

## [1.1.0] - 2025-09-17

### Features

- Add experimental indirection layer for node socketPath
  ([8ee8252](https://github.com/mlabs-haskell/cardano.nix/commit/8ee825291efccbbe313383044d25fff612d42519))

- Add demeter-run-cli package
  ([f7010af](https://github.com/mlabs-haskell/cardano.nix/commit/f7010afbf6716cee5fce217e4516714dd7e04f9e))

### Bug Fixes

- Fix documentation rendering and changelog generation
  ([0c1c75a](https://github.com/mlabs-haskell/cardano.nix/commit/0c1c75a2010fba0b9b8a681da56262caade7cc2c))

### Improvements

- Refactor services to use new provider system for Ogmios, Kupo and db-sync
  ([cf0618a](https://github.com/mlabs-haskell/cardano.nix/commit/cf0618a275d91d4afa049e52ba260346abc4c599))

- Migrate to REUSE.toml for license management
  ([cf9553d](https://github.com/mlabs-haskell/cardano.nix/commit/cf9553d227fc003709ae635ad2292d16db411844))

- Add changelog to website documentation
  ([f79c503](https://github.com/mlabs-haskell/cardano.nix/commit/f79c503014ff0c47221f3917991903b508121a66))

## [1.0.0] - 2025-08-29

### Initial Release

This is the first stable release of cardano-nix. Prior to this version, the project did not follow semantic versioning or maintain a proper changelog.

### Features

This release provides NixOS modules and packages for the Cardano blockchain ecosystem:

**Core Services:**

- **cardano-node** - Cardano blockchain node service
- **ogmios** - WebSocket API for Cardano integration
- **kupo** - UTxO indexing service
- **cardano-db-sync** - Database synchronization service
- **blockfrost** - API service integration
- **oura** - Event streaming service

**Infrastructure:**

- **HTTP proxy** with load balancing capabilities
- **Monitoring stack** with Prometheus and Grafana
- **Private testnet** support for development

**Developer Tools:**

- Comprehensive documentation with auto-generated API reference
- Flake templates for common deployment scenarios
- Pre-commit hooks and development environment
- Binary cache integration via Hercules CI

### Package Versions

- cardano-node: 10.3.1
- ogmios: 6.8.0
- kupo: 2.11.0
- blockfrost: 3.1.0
- oura: 1.9.1

### Notes

- Conway era compatible
- All services include NixOS modules with full configuration options
- Documentation available at GitHub Pages
- Licensed under Apache 2.0

---

_Starting from v1.0.0, this project follows semantic versioning and maintains a proper changelog for all releases._

<!-- generated by git-cliff -->
