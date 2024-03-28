{ lib, config, inputs, ... }:
let
  cfg = config.my-virtualization.arion;
in
with lib;
{
  imports = [
    inputs.arion.nixosModules.arion
  ];

  options.my-virtualization.arion = {
    enable = mkEnableOption "Enable podman with Btrfs storage";
    network.enable = mkEnableOption "Enable DNS on default bridge";
  };
  config = mkIf cfg.enable {
    virtualisation = {
      podman = {
        enable = true;
        autoPrune.enable = true;
        defaultNetwork.settings = mkIf cfg.network.enable {
          dns_enabled = true;
        };
      };
      containers = {
        storage.settings = {
          storage = {
            driver = "btrfs";
            graphroot = "/var/lib/containers/storage";
            runroot = "/run/containers/storage";
          };
        };
      };
      oci-containers.backend = "podman";
      arion.backend = "podman-socket";
    };

    systemd.network.networks = mkIf cfg.network.enable {
      "10-podman0" = {
        name = "podman0";
        linkConfig = {
          ActivationPolicy = "manual";
        };
        networkConfig = {
          KeepConfiguration = "static";
          DNS = "10.88.0.1";
          Domains = "dns.podman";
          DNSDefaultRoute = "no";
        };
      };
    };
  };
}
