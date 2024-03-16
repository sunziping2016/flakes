{ ... }:
{
  networking = {
    useNetworkd = true;
    useDHCP = false;
    firewall.enable = false;
  };

  systemd.network.networks = {
    # man 8 systemd-resolved.service for DNS configuration
    "20-wlan" = {
      name = "wl*";
      DHCP = "yes";
      dhcpV4Config.RouteMetric = 2048;
      dhcpV6Config.RouteMetric = 2048;
    };
    "20-enther" = {
      name = "en*";
      DHCP = "yes";
    };
  };

  systemd.network.wait-online = {
    anyInterface = true;
  };
}
