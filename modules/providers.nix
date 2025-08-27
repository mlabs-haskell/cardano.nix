# Design defence:
# The goal of this module is to introduce an indirection layer for service
# dependencies: consumers reference a provider instead of binding to a specific
# systemd unit. This makes it possible to transparently switch between a local
# cardano-node and a remote tunnel (e.g. from Demeter run). Common options are
# factored into `sharedOptions` to unify the contract and reduce duplication.
# Options are currently marked as `internal = true` until proper documentation
# is written.
{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  sharedOptions = {
    active = mkOption {
      type = types.bool;
      internal = true;
      default = false;
      description = ''
        Mark service provider as active
      '';
    };
    requires = mkOption {
      type = types.str;
      internal = true;
      description = ''
        Systemd's service name to add to `requires` by all consumers
      '';
    };
    after = mkOption {
      type = types.str;
      internal = true;
      description = ''
        Systemd's service name to add to `after` by all consumers
      '';
    };
  };
  socketOptions = name: {
    accessGroup = mkOption {
      type = types.str;
      internal = true;
      description = ''
        Group to access ${name} service provider
      '';
    };
    socketPath = mkOption {
      type = types.path;
      internal = true;
      description = ''
        Path to ${name} socket path, to refer by consumers
      '';
    };
  };
  tcpOptions = name: {
    host = mkOption {
      type = types.str;
      internal = true;
      description = ''
        Host address for TCP connection to ${name}, to refer by consumers.
      '';
    };
    port = mkOption {
      type = types.port;
      internal = true;
      description = ''
        Port address for TCP connection to ${name}, to refer by consumers.
      '';
    };
  };
in
{
  options.cardano.providers = mkOption {
    description = "Abstraction layer to plug in different providers of cardano-node/ogmios/kupo/etc";
    internal = true;
    type = types.submodule {
      options = {
        node = sharedOptions // socketOptions "cardano node";
        ogmios = sharedOptions // tcpOptions "Ogmios";
        kupo = sharedOptions // tcpOptions "Kupo";
      };
    };
  };
}
