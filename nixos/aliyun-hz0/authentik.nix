{ config, pkgs, lib, ... }:
let
  host = "auth.szp15.com";
in
{
  sops.secrets = {
    "authentik.secret-key" = { };
    "authentik.email.host" = { };
    "authentik.email.port" = { };
    "authentik.email.username" = { };
    "authentik.email.password" = { };
    "authentik.password" = { };
    "authentik.token" = { };
    "authentik.email" = { };
  };

  sops.templates."authentik_env_file" = {
    content = ''
      AUTHENTIK_SECRET_KEY="${config.sops.placeholder."authentik.secret-key"}"
      AUTHENTIK_EMAIL__HOST="${config.sops.placeholder."authentik.email.host"}"
      AUTHENTIK_EMAIL__PORT="${config.sops.placeholder."authentik.email.port"}"
      AUTHENTIK_EMAIL__USERNAME="${config.sops.placeholder."authentik.email.username"}"
      AUTHENTIK_EMAIL__PASSWORD="${config.sops.placeholder."authentik.email.password"}"
      AUTHENTIK_EMAIL__FROM="${config.sops.placeholder."authentik.email.username"}"
      AUTHENTIK_EMAIL__USE_TLS="true"
      AUTHENTIK_BOOTSTRAP_PASSWORD="${config.sops.placeholder."authentik.password"}"
      AUTHENTIK_BOOTSTRAP_TOKEN="${config.sops.placeholder."authentik.token"}"
      AUTHENTIK_BOOTSTRAP_EMAIL="${config.sops.placeholder."authentik.email"}"
    '';
  };

  users.groups = {
    authentik = {
      gid = 800;
    };
  };
  users.users = {
    authentik = {
      uid = 800;
      isSystemUser = true;
      group = "authentik";
    };
  };

  virtualisation.arion.projects.authentik.settings =
    let
      version = "2023.10.6";
    in
    {
      services = {
        postgresql = {
          service.image = "docker.io/library/postgres:12-alpine";
          service.restart = "unless-stopped";
          service.healthcheck = {
            test = [ "CMD-SHELL" "pg_isready -d $\${POSTGRES_DB} -U $\${POSTGRES_USER}" ];
            start_period = "20s";
            interval = "30s";
            retries = 5;
            timeout = "5s";
          };
          service.volumes = [
            "database:/var/lib/postgresql/data"
          ];
          service.environment = {
            POSTGRES_PASSWORD = "password";
            POSTGRES_USER = "authentik";
            POSTGRES_DB = "authentik";
          };
          service.env_file = [
            config.sops.templates."authentik_env_file".path
          ];
        };
        redis = {
          service.image = "docker.io/library/redis:6-alpine";
          service.command = "--save 60 1 --loglevel warning";
          service.restart = "unless-stopped";
          service.healthcheck = {
            test = [ "CMD-SHELL" "redis-cli ping | grep PONG" ];
            start_period = "20s";
            interval = "30s";
            retries = 5;
            timeout = "5s";
          };
          service.volumes = [
            "redis:/data"
          ];
        };
        server = {
          service.image = "ghcr.io/goauthentik/server:${version}";
          service.restart = "unless-stopped";
          service.command = "server";
          service.environment = {
            AUTHENTIK_REDIS__HOST = "redis";
            AUTHENTIK_POSTGRESQL__HOST = "postgresql";
            AUTHENTIK_POSTGRESQL__USER = "authentik";
            AUTHENTIK_POSTGRESQL__NAME = "authentik";
            AUTHENTIK_POSTGRESQL__PASSWORD = "password";
          };
          service.volumes = [
            "/srv/authentik/media:/media"
            "/srv/authentik/custom-templates:/templates"
          ];
          service.env_file = [
            config.sops.templates."authentik_env_file".path
          ];
          service.ports = [
            "127.0.0.1:49322:9443"
          ];
          service.depends_on = [
            "postgresql"
            "redis"
          ];
          service.user = "800:800";
        };
        worker = {
          service.image = "ghcr.io/goauthentik/server:${version}";
          service.restart = "unless-stopped";
          service.command = "worker";
          service.environment = {
            AUTHENTIK_REDIS__HOST = "redis";
            AUTHENTIK_POSTGRESQL__HOST = "postgresql";
            AUTHENTIK_POSTGRESQL__USER = "authentik";
            AUTHENTIK_POSTGRESQL__NAME = "authentik";
            AUTHENTIK_POSTGRESQL__PASSWORD = "password";
          };
          service.volumes = [
            "/srv/authentik/media:/media"
            # Authentik discovers keys in /certs every hour.
            # Wait for an hour to see if it works.
            "\${CREDENTIALS_DIRECTORY:?credentials directory required}:/certs"
            "/srv/authentik/custom-templates:/templates"
          ];
          service.env_file = [
            config.sops.templates."authentik_env_file".path
          ];
          service.depends_on = [
            "postgresql"
            "redis"
          ];
          service.user = "800:800";
        };
      };
      docker-compose.volumes = {
        database = { };
        redis = { };
      };
    };

  systemd.tmpfiles.rules = [
    "d /srv/authentik/media 0755 authentik authentik -"
    "d /srv/authentik/custom-templates 0755 authentik authentik -"
  ];

  systemd.services.arion-authentik = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      LoadCredential = [
        "${host}.pem:${config.security.acme.certs.${host}.directory}/fullchain.pem"
        "${host}.key:${config.security.acme.certs.${host}.directory}/key.pem"
      ];
      # Execute with root permissions.
      ExecStart =
        let
          script = (pkgs.writeShellScriptBin "arion-authentik-start" ''
            set -e
            ${config.systemd.services.arion-authentik.script}
          '').overrideAttrs (_: {
            name = "unit-script-arion-authentik-start";
          });
        in
        lib.mkForce "+${script}/bin/arion-authentik-start";
      User = "authentik";
      Group = "authentik";
    };
  };

  services.nginx = {
    enable = true;

    virtualHosts."${host}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "https://127.0.0.1:49322";
      };
    };
  };
}
