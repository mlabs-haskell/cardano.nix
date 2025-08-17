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
    accessGroup = mkOption {
      type = types.str;
      internal = true;
      description = ''
        Group to access service provider
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
in
{
  options.cardano.providers = {
    node = sharedOptions // {
      socketPath = mkOption {
        type = types.path;
        description = ''
          Cardano node socket path, to refer by consumers
        '';
      };
    };
  };
}
