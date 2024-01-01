{ config, ... }:
let
  sslCertDir = "${config.security.acme.certs."idm.szp15.com".directory}";
in
{
  services.kanidm = {
    enableServer = true;
    serverSettings = {
      bindaddress = "[::1]:24557";
      ldapbindaddress = "[::]:636";
      domain = "idm.szp15.com";
      origin = "https://idm.szp15.com";
      tls_chain = "${sslCertDir}/fullchain.pem";
      tls_key = "${sslCertDir}/key.pem";
    };
  };

  users.groups = {
    kanidm-acme = { };
  };

  users.users = {
    kanidm.extraGroups = [ "kanidm-acme" ];
    nginx.extraGroups = [ "kanidm-acme" ];
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "me@szp.io";
      webroot = "/var/lib/acme/acme-challenge";
    };
  };

  security.acme.certs = {
    "idm.szp15.com" = {
      group = "kanidm-acme";
    };
  };

  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    recommendedZstdSettings = true;

    # Maybe we can use tcp forwarding based on SNI. See <https://stackoverflow.com/a/40135151>.
    virtualHosts."idm.szp15.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://[::1]:24557";
        extraConfig = ''
          proxy_ssl_server_name on;
          proxy_ssl_verify off;
        '';
      };
    };
  };
}
