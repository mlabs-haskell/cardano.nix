{
  flake.templates = {
    default = {
      path = ./default;
      description = "Example flake using cardano.nix";
    };
    cluster = {
      path = ./cluster;
      description = "Example flake for deploying a cardano.nix cluster with multiple nodes, load balancer and monitoring";
    };
  };
}
