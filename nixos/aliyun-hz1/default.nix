{ config, ... }:
{
  imports = [
    ../aliyun-common
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets = {
    "openldap.root-password" = {
      key = "root-password";
      owner = "openldap";
      group = "openldap";
    };
    "keycloak.database-password" = { };
  };


  my-services.openldap = {
    enable = true;
    rootPasswordFile = config.sops.secrets."openldap.root-password".path;
  };

  my-services.keycloak = {
    enable = true;
    databasePasswordFile = config.sops.secrets."keycloak.database-password".path;
  };
}
