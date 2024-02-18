{ config, ... }:
let
  host = "ocis.szp15.com";
in
{
  sops.secrets = {
    "ocis.s3.endpoint" = { };
    "ocis.s3.access-key" = { };
    "ocis.s3.secret-key" = { };
    "ocis.s3.bucket" = { };
    "ocis.ldap.password" = { };
  };

  sops.templates."ocis_env_file" = {
    content = ''
      STORAGE_USERS_S3NG_ENDPOINT=${config.sops.placeholder."ocis.s3.endpoint"}
      STORAGE_USERS_S3NG_ACCESS_KEY=${config.sops.placeholder."ocis.s3.access-key"}
      STORAGE_USERS_S3NG_SECRET_KEY=${config.sops.placeholder."ocis.s3.secret-key"}
      STORAGE_USERS_S3NG_BUCKET=${config.sops.placeholder."ocis.s3.bucket"}
      OCIS_LDAP_BIND_PASSWORD=${config.sops.placeholder."ocis.ldap.password"}
    '';
  };

  virtualisation.arion.projects.ocis.settings =
    let
      version = "4.0.5";
    in
    {
      services = {
        ocis.service = {
          image = "docker.io/owncloud/ocis:${version}";
          entrypoint = "/bin/sh";
          command = [ "-c" "ocis init || true; ocis server" ];
          environment = {
            OCIS_URL = "https://${host}";
            OCIS_LOG_LEVEL = "debug";
            OCIS_INSECURE = "false";
            PROXY_TLS = "false";
            # storage
            STORAGE_USERS_DRIVER = "s3ng";
            STORAGE_SYSTEM_DRIVER = "ocis";
            # LDAP
            OCIS_LDAP_URI = "ldaps://auth.szp15.com";
            OCIS_LDAP_BIND_DN = "cn=ocis-ldap-service,ou=users,ou=ocis,dc=ldap,dc=szp,dc=io";

            OCIS_LDAP_GROUP_BASE_DN = "ou=groups,ou=ocis,dc=ldap,dc=szp,dc=io";
            OCIS_LDAP_GROUP_FILTER = "(&(objectClass=groupOfNames)(member=cn=oCIS Groups,ou=groups,ou=ocis,dc=ldap,dc=szp,dc=io))";
            OCIS_LDAP_USER_BASE_DN = "ou=users,ou=ocis,dc=ldap,dc=szp,dc=io";
            OCIS_LDAP_USER_FILTER = "(&(objectClass=inetOrgPerson)(memberOf=cn=oCIS Users,ou=groups,ou=ocis,dc=ldap,dc=szp,dc=io))";
            # LDAP login
            LDAP_LOGIN_ATTRIBUTES = "mail";
            IDP_LDAP_LOGIN_ATTRIBUTE = "mail";
            OCIS_LDAP_USER_SCHEMA_USERNAME = "mail";
            # LDAP uid
            OCIS_LDAP_USER_SCHEMA_ID = "uid";
            IDP_LDAP_UUID_ATTRIBUTE = "uid";
            IDP_LDAP_UUID_ATTRIBUTE_TYPE = "text";
            # other settings
            GRAPH_LDAP_SERVER_WRITE_ENABLED = "false";
            OCIS_EXCLUDE_RUN_SERVICES = "idm";
            OCIS_LDAP_INSECURE = "true";
          };
          env_file = [
            config.sops.templates."ocis_env_file".path
          ];
          volumes = [
            "ocis-config:/etc/ocis"
            "ocis-data:/var/lib/ocis"
          ];
          ports = [
            "127.0.0.1:9302:9200"
          ];
          restart = "unless-stopped";
        };
      };
      docker-compose.volumes = {
        "ocis-config" = { };
        "ocis-data" = { };
      };
    };

  systemd.services.arion-ocis = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };

  services.nginx.virtualHosts."${host}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:9302";
      extraConfig = ''
        proxy_buffers 4 256k;
        proxy_buffer_size 128k;
        proxy_busy_buffers_size 256k;
        client_max_body_size 0;
      '';
    };
  };
}
