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
          olcLogLevel = "conns config";
        };
        children = {
          "cn=schema".includes = [
            "${pkgs.openldap}/etc/schema/core.ldif"
            "${pkgs.openldap}/etc/schema/cosine.ldif"
            "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
          ];

          "olcDatabase={1}mdb".attrs = {
            objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];

            olcDatabase = "{1}mdb";
            olcDbDirectory = "/var/lib/openldap/data";

            olcSuffix = "dc=szp,dc=io";

            /* your admin account, do not use writeText on a production system */
            olcRootDN = "cn=admin,dc=szp,dc=io";
            olcRootPW.path = cfg.rootPasswordFile;

            olcDbIndex = [
              "objectClass eq,pres"
              "ou,cn,mail,surname,givenname eq,pres,sub"
            ];

            olcAccess = [
              /* custom access rules for userPassword attributes */
              ''{0}to attrs=userPassword
                by self write
                by * none''

              /* allow read on anything else */
              ''{1}to *
                by anonymous none
                by * read''
            ];
          };
        };
      };
    };
  };
}
