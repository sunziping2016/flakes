# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ pkgs, config, ... }:
{
  imports = [
    ./hardware.nix
    ./nvidia.nix
    ./xfce.nix
    ./ldap.nix
  ];

  # For cross compile
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/efi";

  networking = {
    hostName = "nixos";
    wireless.iwd.enable = true;
  };

  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "C.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-chinese-addons
      ];
    };
  };

  fonts.enableDefaultPackages = false;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    jetbrains-mono
    (nerdfonts.override { fonts = [ "JetBrainsMono" "RobotoMono" ]; })
  ];
  fonts.fontconfig.defaultFonts = pkgs.lib.mkForce {
    serif = [ "Noto Serif" "Noto Serif CJK SC" ];
    sansSerif = [ "Noto Sans" "Noto Sans CJK SC" ];
    monospace = [ "JetBrains Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.defaultSession = "xfce";
    # See microsoft/vscode#23991 to make VS Code follow the keyboard mappings.
    xkb.options = "caps:escape";
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  hardware.bluetooth.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.virtualization = {
    enable = true;
    network.enable = true;
  };
  environment.sing-box = {
    enable = true;
    outboundFile = config.sops.secrets."sing-box-outbound.json".path;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  sops = {
    defaultSopsFile = ../secrets.yaml;
    # see Mic92/sops-nix#167 for setting up with impermanence
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];
    secrets = {
      "iwd.ChinaNet-sun" = { };
      "users.sun.hashedPassword".neededForUsers = true;
      "sing-box-outbound.json" = { };
    };
  };

  users.users.sun = {
    isNormalUser = true;
    extraGroups = [ "wheel" "podman" ];
    hashedPasswordFile = config.sops.secrets."users.sun.hashedPassword".path;
    shell = pkgs.fish;
  };
  programs.fish.enable = true;


  security.sudo = {
    extraConfig = ''
      Defaults lecture="never"
    '';
    wheelNeedsPassword = false;
  };

  systemd.tmpfiles.rules = [
    "C /var/lib/iwd/ChinaNet-sun.psk       - - - - ${config.sops.secrets."iwd.ChinaNet-sun".path}"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # extra man pages
    pkgs.man-pages
    pkgs.man-pages-posix
  ];
  programs._1password-gui.enable = true;

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
    users.sun = {
      directories = [
        ".cache"
        ".config"
        ".local"
        ".npm"
        ".vscode"
        "Documents"
        "Downloads"
        "Projects"
        { directory = ".ssh"; mode = "0700"; }
        { directory = ".gnupg"; mode = "0700"; }
      ];
    };
  };

  nix.settings.trusted-users = [ "root" "sun" ];
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.pcscd.enable = true;
  services.gnome.gnome-keyring.enable = true;

  programs.steam.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system.stateVersion = "23.11";
}
