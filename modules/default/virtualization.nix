{ lib, config, ... }:
let
  cfg = config.environment.virtualization;
in
with lib;
{
  options.environment.virtualization = {
    enable = mkEnableOption "Enable podman with Btrfs storage";
    network.enable = mkEnableOption "Enable DNS on default bridge";
  };
  config = mkIf cfg.enable {
    environment.persistence."/persist" = {
      directories = [
        "/var/lib/containers"
      ];
    };

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
