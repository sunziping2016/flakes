{ lib, config, pkgs, ... }:
let
  cfg = config.environment.sing-box;
  settings = {
    log.level = "info";
    experimental.cache_file = {
      enabled = true;
      path = "/var/cache/sing-box/cache.db";
      store_fakeip = true;
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
          rule_set = "geosite-category-ads-all";
          server = "block";
          disable_cache = true;
        }
        {
          outbound = "any";
          server = "local";
        }
        {
          rule_set = [
            "geosite-geolocation-cn"
            "geosite-steam"
          ];
          server = "local";
        }
        # Will be changed to compiled rule sets in sing-box v1.8.0
        {
          domain_suffix = [
            "szp15.com"
            "aliyuncs.com"
          ];
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
      strategy = "prefer_ipv4";
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
        listen = "::1";
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
          ip_is_private = true;
          outbound = "direct";
        }
        {
          rule_set = [
            "geoip-cn"
            "geosite-geolocation-cn"
          ];
          outbound = "direct";
        }
        {
          rule_set = "geosite-category-ads-all";
          outbound = "block";
        }
      ];
      rule_set = [
        {
          tag = "geoip-cn";
          type = "remote";
          format = "binary";
          url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs";
        }
        {
          tag = "geosite-geolocation-cn";
          type = "remote";
          format = "binary";
          url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-geolocation-cn.srs";
        }
        {
          tag = "geosite-steam";
          type = "remote";
          format = "binary";
          url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-steam.srs";

        }
        {
          tag = "geosite-category-ads-all";
          type = "remote";
          format = "binary";
          url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ads-all.srs";
        }
      ];
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
