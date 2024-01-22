{ config, ... }: {
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.szp15.com";
    useSubstitutes = true;
    notificationSender = "hydra@szp.io";
    buildMachinesFiles = [ ];
    listenHost = "127.0.0.1";
    port = 48569;
    extraConfig = ''
      <ldap>
        <config>
          <credential>
            class = Password
            password_field = password
            password_type = self_check
          </credential>
          <store>
            class = LDAP
            ldap_server = "ldaps://idm.szp15.com"
            <ldap_server_options>
              timeout = 30
            </ldap_server_options>
            binddn = "dn=token"
            include ${config.sops.templates."hydra-ldap-password.conf".path}
            start_tls = 0
            <start_tls_options>
              verify = none
            </start_tls_options>
            user_basedn = "dc=idm,dc=szp15,dc=com"
            user_filter = "(&(class=person)(name=%s))"
            user_scope = one
            user_field = name
            <user_search_options>
              attrs = "+"
              attrs = "cn"
              deref = always
            </user_search_options>
            use_roles = 1
            role_basedn = "dc=idm,dc=szp15,dc=com"
            role_filter = "(&(class=group)(member=%s))"
            role_scope = one
            role_field = name
            role_value = spn
            <role_search_options>
              attrs = "+"
              attrs = "cn"
              deref = always
            </role_search_options>
          </store>
        </config>
        <role_mapping>
          hydra_admin = admin
          hydra_admin = create-projects
          hydra_admin = bump-to-front
          hydra_dev = restart-jobs
          hydra_dev = cancel-build
        </role_mapping>
      </ldap>

      <git-input>
        timeout = 3600
      </git-input>
    '';
  };

  services.nginx.virtualHosts."hydra.szp15.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://127.0.0.1:48569";
  };
}
