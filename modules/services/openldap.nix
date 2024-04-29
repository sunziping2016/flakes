{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.my-services.openldap;
in
{
  options.my-services.openldap = {
    enable = mkEnableOption "Enable the LDAP server";
    rootPasswordFile = mkOption {
      type = types.path;
      description = "Path to the file containing the root password for the LDAP server";
    };
  };

  config = mkIf cfg.enable {
    services.openldap = {
      enable = true;

      # TODO: TLS
      urlList = [ "ldap:///" ];

      settings = {
        attrs = {
          olcLogLevel = "0";
        };
        children = {
          "cn=schema".includes = [
            "${pkgs.openldap}/etc/schema/core.ldif"
            "${pkgs.openldap}/etc/schema/cosine.ldif"
            "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
            "${pkgs.openldap}/etc/schema/nis.ldif"
          ];

          "olcDatabase={1}mdb".attrs = {
            objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];
            olcDatabase = "{1}mdb";
            olcDbDirectory = "/var/lib/openldap/data";
            olcRootPW.path = cfg.rootPasswordFile;
            olcRootDN = "cn=admin,dc=szp,dc=io";
            olcSuffix = "dc=szp,dc=io";
            olcAccess = [
              /* custom access rules for userPassword attributes */
              ''{0}to attrs=userPassword
                  by self write
                  by anonymous auth
                  by * none''

              ''{1}to * by * read''
            ];
          };
        };
      };
    };
  };
}
