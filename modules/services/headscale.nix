{ lib, config, ... }:
with lib;
let
  cfg = config.my-services.headscale;
  domain = "headscale.szp15.com";
in
{
  options.my-services.headscale = {
    enable = mkEnableOption "Enable Headscale server";
  };

  config = mkIf cfg.enable {
    services.headscale = {
      enable = true;
      address = "127.0.0.1";
      port = config.ports.headscale;
      settings = {
        server_url = "https://${domain}";
        ip_prefixes = [
          "fd7a:115c:a1e0::/48"
          "100.64.0.0/10"
        ];
        disable_check_updates = true;
        dns_config = {
          base_domain = "szp.io";
          extra_records = [
            {
              name = "headscale.internal.szp.io";
              type = "A";
              value = "100.64.0.1";
            }
          ];
        };
        derp.server = {
          enabled = true;
          region_id = 999;
          region_code = "headscale";
          region_name = "Headscale Embedded DERP";
          stun_listen_addr = "0.0.0.0:3478";
          private_key_path = "/var/lib/headscale/derp_server_private.key";
          automatically_add_embedded_derp_region = true;
        };
        derp.urls = [ ];
      };
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.ports.headscale}";
        proxyWebsockets = true;
      };
    };
  };
}
