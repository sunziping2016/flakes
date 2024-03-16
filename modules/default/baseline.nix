{ lib, self, inputs, ... }:
with lib;
{
  config = {
    boot = {
      kernel.sysctl = {
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };
    };
    nix.registry.p.flake = self;
    nix.settings = {
      nix-path = [ "nixpkgs=${inputs.nixpkgs}" ];
      auto-optimise-store = true;
      flake-registry = "/etc/nix/registry.json";
      experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
      use-cgroups = true;
    };

    # Only take effect when security.acme.enable is true
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "me@szp.io";
        webroot = "/var/lib/acme/acme-challenge";
      };
    };
  };
}
