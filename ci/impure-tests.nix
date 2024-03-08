{
  withSystem,
  config,
  ...
}: {
  # TODO map over all tests and add impure oens as effects

  herculesCI.onPush.default.outputs.effects.testing-cardano-node = withSystem config.defaultEffectSystem ({
    hci-effects,
    config,
    ...
  }:
    hci-effects.modularEffect {
      extraAttributes.__hci_effect_mounts."/dev/kvm" = "kvm";
      effectScript = ''
        ${(config.cardanoNix._mkCheckFromTest config.cardanoNix.tests.cardano-node).driver}/bin/nixos-test-driver
      '';
    });
}
