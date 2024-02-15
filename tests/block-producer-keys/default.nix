{
  environment = {
    # We provide keys in copy mode with correct permissions - otherwise cardano-node rejects.
    etc = {
      "cardano/kes.skey" = {
        source = ./kes.skey;
        mode = "400";
        user = "cardano-node";
      };
      "cardano/vrf.skey" = {
        source = ./vrf.skey;
        mode = "400";
        user = "cardano-node";
      };
      "cardano/opcert.cert" = {
        source = ./opcert.cert;
        mode = "400";
        user = "cardano-node";
      };
    };
  };
  cardanoNix.cardano-node.producer.shelleyEraKeys = {
    kesKey = "/etc/cardano/kes.skey";
    vrfKey = "/etc/cardano/vrf.skey";
    operationalCertificate = "/etc/cardano/opcert.cert";
  };
}
