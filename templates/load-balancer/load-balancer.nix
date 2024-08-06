{
  cardano.http.enable = true;

  services.http-proxy = {
    domainName = "cardano.example.com";
    backends = [
      "node1.cardano.example.com"
      "node2.cardano.example.com"
      "node3.cardano.example.com"
    ];
  };
}
