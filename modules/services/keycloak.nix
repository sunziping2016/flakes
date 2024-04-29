{ lib, config, ... }:
with lib;
let
  cfg = config.my-services.keycloak;
  domain = "auth.szp15.com";
  sslCertDir = "${config.security.acme.certs."${domain}".directory}";
in
{
  options.my-services.keycloak = {
    enable = mkEnableOption "Enable Keycloak server";
    databasePasswordFile = mkOption {
      type = types.str;
      description = "Path to the file containing the password for the Keycloak database user";
    };
  };

  config = mkIf cfg.enable {
    services.keycloak = {
      enable = true;

      sslCertificate = "${sslCertDir}/fullchain.pem";
      sslCertificateKey = "${sslCertDir}/key.pem";

      database = {
        type = "postgresql";
        createLocally = true;
        username = "keycloak";
        passwordFile = cfg.databasePasswordFile;
      };

      # https://www.keycloak.org/server/all-config
      settings = {
        hostname = domain;
        https-port = config.ports.keycloak;
        proxy-headers = "xforwarded";
      };
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://127.0.0.1:${toString config.ports.keycloak}";
      };
    };
  };
}
