{ lib, config, pkgs, ... }:
let
  cfg = config.environment.sing-box;
  settings = {
    log.level = "info";
    experimental.clash_api = {
      store_fakeip = true;
      cache_file = "/var/cache/sing-box/cache.db";
    };
    dns = {
      servers = [
        {
          address = "tls://8.8.8.8";
        }
        {
          tag = "local";
          address = "223.5.5.5";
          detour = "direct";
        }
        {
          tag = "remote";
          address = "fakeip";
        }
        {
          tag = "block";
          address = "rcode://success";
        }
      ];
      rules = [
        {
          geosite = "category-ads-all";
          server = "block";
          disable_cache = true;
        }
        {
          outbound = "any";
          server = "local";
        }
        {
          geosite = "cn";
          server = "local";
        }
        {
          query_type = [ "A" "AAAA" ];
          server = "remote";
        }
      ];
      fakeip = {
        enabled = true;
        inet4_range = "198.18.0.0/15";
        inet6_range = "fc00::/18";
      };
      independent_cache = true;
      strategy = "ipv4_only";
    };
    outbounds = [
      {
        type = "direct";
        tag = "direct";
      }
      {
        type = "block";
        tag = "block";
      }
      {
        type = "dns";
        tag = "dns-out";
      }
    ];
    inbounds = [
      {
        type = "tun";
        interface_name = "sing0";
        inet4_address = "172.19.0.1/30";
        sniff = true;
      }
      {
        type = "mixed";
        listen = "::";
        listen_port = 12311;
      }
    ];
    route = {
      rules = [
        {
          protocol = "dns";
          outbound = "dns-out";
        }
        {
          geosite = "cn";
          geoip = [ "private" "cn" ];
          outbound = "direct";
        }
        {
          geosite = "category-ads-all";
          outbound = "block";
        }
      ];
      geosite.path = "${pkgs.sing-geosite}/share/sing-box/geosite.db";
      geoip.path = "${pkgs.sing-geoip}/share/sing-box/geoip.db";
      auto_detect_interface = true;
    };
  };
in
with lib;
{
  options.environment.sing-box = {
    enable = mkEnableOption "Enable sing-box TUN proxy";
    package = lib.mkPackageOptionMD pkgs "sing-box" { };
    outboundFile = mkOption { type = types.path; };
  };
  config = mkIf cfg.enable {
    systemd.network.networks = {
      "10-sing0" = {
        name = "sing0";
        linkConfig = {
          RequiredForOnline = "no";
        };
        networkConfig = {
          Address = "172.19.0.1/30";
          DNS = "172.19.0.2";
          DNSDefaultRoute = "no";
          ConfigureWithoutCarrier = "yes";
          Domains = "~.";
        };
        routes = [{
          routeConfig = {
            Destination = "198.18.0.0/15";
          };
        }];
      };
    };

    systemd.network.netdevs = {
      "10-sing0" = {
        netdevConfig = {
          Name = "sing0";
          Kind = "tun";
        };
      };
    };

    systemd.services.sing-box = {
      enable = true;
      description = "Sing-box networking service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        umask 0077
        mkdir -p /etc/sing-box
        ${pkgs.jq}/bin/jq -s '.[1] as $outbound | .[0] | (.outbounds |= [$outbound] + .)' \
          - "$CREDENTIALS_DIRECTORY/outbound.json" > "$CACHE_DIRECTORY/config.json" << EOF
        ${builtins.toJSON settings}
        EOF
      '';
      serviceConfig = {
        LoadCredential = "outbound.json:${cfg.outboundFile}";
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
