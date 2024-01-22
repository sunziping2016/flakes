{ config, modulesPath, data, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    # ./idm.nix
    # ./hydra.nix
    ./firefly.nix
    ./authentik.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/efi";
  services.openssh.enable = true;

  sops = {
    defaultSopsFile = ../secrets.yaml;
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];
    secrets = {
      "sing-box-outbound.json" = { };
      # "hydra.ldap.token" = { };
    };

    # templates = {
    #   "hydra-ldap-password.conf" = {
    #     content = ''
    #       bindpw = "${config.sops.placeholder."hydra.ldap.token"}"
    #     '';
    #     mode = "0440";
    #     owner = "hydra";
    #     group = "hydra";
    #   };
    # };
  };

  users.users.root.openssh.authorizedKeys.keys = data.keys;

  environment.baseline.enable = true;
  environment.virtualization.enable = true;
  environment.sing-box = {
    enable = true;
    outboundFile = config.sops.secrets."sing-box-outbound.json".path;
  };

  environment.persistence."/persist" = {
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
    directories = [
      "/var/lib"
      "/var/log"
      # workaround for OOM caused by nix-build
      "/tmp"
      # service data
      "/srv"
    ];
  };

  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    recommendedZstdSettings = true;
  };

  system.stateVersion = "23.11";
}
