{ config, modulesPath, data, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./idm.nix
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
    };
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
    ];
  };

  system.stateVersion = "23.11";
}
