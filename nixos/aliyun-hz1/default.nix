{ config, ... }:
{
  imports = [
    ../aliyun-common
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets."openldap.root-password" = {
    key = "root-password";
    owner = "openldap";
    group = "openldap";
  };


  my-services.openldap = {
    enable = true;
    rootPasswordFile = config.sops.secrets."openldap.root-password".path;
  };
}
