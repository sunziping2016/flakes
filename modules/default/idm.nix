{ pkgs, ... }: {
  services.kanidm = {
    enableClient = true;
    enablePam = true;
    clientSettings = {
      uri = "https://idm.szp15.com";
    };
    unixSettings = {
      pam_allowed_login_groups = [ "posix_group" ];
    };
  };

  environment.etc."ssh/auth" = {
    mode = "0555";
    text = ''
      #!${pkgs.stdenv.shell}
      ${pkgs.kanidm}/bin/kanidm_ssh_authorizedkeys "$@"
    '';
  };

  services.openssh = {
    authorizedKeysCommand = "/etc/ssh/auth %u";
    authorizedKeysCommandUser = "nobody";
  };
}
