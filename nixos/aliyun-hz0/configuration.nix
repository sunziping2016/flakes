{ modulesPath, data, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/efi";
  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = data.keys;

  system.stateVersion = "23.11";
}
