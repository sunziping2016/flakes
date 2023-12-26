{ config, ... }:
let
  sslCertDir = "${config.security.acme.certs."idm.szp15.com".directory}";
in
{
  services.kanidm = {
    enableServer = true;
    serverSettings = {
      bindaddress = "[::1]:24557";
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
    caddy.extraGroups = [ "kanidm-acme" ];
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
      reloadServices = [ "kanidm.service" ];
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "http://" = {
        logFormat = ''
          output file ${config.services.caddy.logDir}/access-acme.log
        '';
        extraConfig = ''
          handle /.well-known/acme-challenge/* {
            root * ${config.security.acme.defaults.webroot}
            file_server
          }
        '';
      };
      "idm.szp15.com" = {
        useACMEHost = "idm.szp15.com";
        extraConfig = ''
          reverse_proxy [::1]:24557 {
            transport http {
              tls_insecure_skip_verify
            }
          }
        '';
      };
    };
    email = config.security.acme.defaults.email;
  };
}
