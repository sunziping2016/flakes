{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.my-services.sing-box;
in
{
  options.my-services.sing-box = {
    enable = mkEnableOption "Enable sing-box TUN proxy";
    package = mkPackageOption pkgs "sing-box" { };
  };

  config = mkIf cfg.enable {
    sops.secrets."sing-box.outbounds.json" = {
      key = "outbounds.json";
      sopsFile = ./sing-box.secrets.yaml;
    };

    systemd.network.netdevs."10-sing0" = {
      netdevConfig = {
        Name = "sing0";
        Kind = "tun";
      };
    };

    systemd.network.networks."10-sing0" = {
      name = "sing0";
      linkConfig = {
        RequiredForOnline = "no";
      };
      # this should match the tun inbound and fake IP in sing-box.json
      networkConfig = {
        Address = [
          "172.19.0.1/30"
          # fake IP
          "198.18.0.0/15"
          "fc00::/18"
        ];
        DNS = "172.19.0.2";
        DNSDefaultRoute = "no";
        ConfigureWithoutCarrier = "yes";
        Domains = "~.";
      };
    };

    systemd.services.sing-box = {
      enable = true;
      description = "Sing-box networking service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        umask 0077
        ${pkgs.jq}/bin/jq -s '.[1] as $outbounds | .[0] | (.outbounds |= $outbounds + .)' \
          "$CREDENTIALS_DIRECTORY/config.tpl.json" "$CREDENTIALS_DIRECTORY/outbounds.json" \
          > "$CACHE_DIRECTORY/config.json"
      '';
      serviceConfig = {
        LoadCredential = [
          "outbounds.json:${config.sops.secrets."sing-box.outbounds.json".path}"
          "config.tpl.json:${./sing-box.json}"
        ];
        ExecStart = "${cfg.package}/bin/sing-box run -c \"\${CACHE_DIRECTORY}/config.json\"";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        WorkingDirectory = "/tmp";
        Restart = "on-failure";
        DynamicUser = "yes";
        User = "sing-box";
        Group = "sing-box";
        CacheDirectory = "sing-box";
        ConfigurationDirectory = "sing-box";
      };
    };
  };
}
