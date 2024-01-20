{ config, ... }: {
  sops.secrets = {
    "authentik.outposts.ldap.token" = { };
  };

  sops.templates."authentik_outpost_ldap_env_file" = {
    content = ''
      AUTHENTIK_HOST="https://auth.szp15.com"
      AUTHENTIK_INSECURE="false"
      AUTHENTIK_TOKEN="${config.sops.placeholder."authentik.outposts.ldap.token"}"
    '';
  };


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

  virtualisation.arion.projects.authentik_outpost_ldap.settings =
    let
      version = "2023.10.6";
    in
    {
      services = {
        authentik_ldap = {
          service.image = "ghcr.io/goauthentik/ldap";
          service.ports = [
            "127.0.0.1:9248:6636"
          ];
          service.env_file = [
            config.sops.templates."authentik_outpost_ldap_env_file".path
          ];
        };
      };
    };

  systemd.services.arion-authentik_outpost_ldap = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };

  services.nginx.virtualHosts."hydra.szp15.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://127.0.0.1:48569";
  };
}
