# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ pkgs, config, ... }:

{
  imports = [
    ./hardware.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/efi";

  networking = {
    hostName = "nixos";
    useNetworkd = true;
    useDHCP = false;
    wireless.iwd.enable = true;
  };
  systemd.network.networks = {
    "10-sing0" = {
      name = "sing0";
      networkConfig = {
        Address = "172.19.0.1/30";
        DNS = "172.19.0.2";
        DNSDefaultRoute = "no";
        ConfigureWithoutCarrier = "yes";
        Domains = "~.";
      };
      routes = [{
        routeConfig = {
          Destination = "198.18.0.0/15";
        };
      }];
    };
    "20-wlan" = {
      name = "wl*";
      DHCP = "yes";
      dhcpV4Config.RouteMetric = 2048;
      dhcpV6Config.RouteMetric = 2048;
    };
    "20-enther" = {
      name = "en*";
      DHCP = "yes";
    };
  };
  systemd.network.netdevs = {
    sing0 = {
      netdevConfig = {
        Name = "sing0";
        Kind = "tun";
      };
    };
  };

  sops.templates."sing-box.json" = {
    content = ''
      {
        "experimental": {
          "clash_api": {
            "store_fakeip": true
          }
        },
        "dns": {
          "servers": [
            {
              "tag": "google",
              "address": "tls://8.8.8.8"
            },
            {
              "tag": "local",
              "address": "223.5.5.5",
              "detour": "direct"
            },
            {
              "tag": "remote",
              "address": "fakeip"
            },
            {
              "tag": "block",
              "address": "rcode://success"
            }
          ],
          "rules": [
            {
              "geosite": "category-ads-all",
              "server": "block",
              "disable_cache": true
            },
            {
              "outbound": "any",
              "server": "local"
            },
            {
              "geosite": "cn",
              "server": "local"
            },
            {
              "query_type": ["A", "AAAA"],
              "server": "remote"
            }
          ],
          "fakeip": {
            "enabled": true,
            "inet4_range": "198.18.0.0/15",
            "inet6_range": "fc00::/18"
          },
          "independent_cache": true,
          "strategy": "ipv4_only"
        },
        "inbounds": [
          {
            "type": "tun",
            "interface_name": "sing0",
            "inet4_address": "172.19.0.1/30",
            "sniff": true
          },
          {
            "type": "mixed",
            "listen": "::",
            "listen_port": 12311
          }
        ],
        "outbounds": [
          ${config.sops.placeholder."sing-box.outbounds.default"},
          {
            "type": "direct",
            "tag": "direct"
          },
          {
            "type": "block",
            "tag": "block"
          },
          {
            "type": "dns",
            "tag": "dns-out"
          }
        ],
        "route": {
          "rules": [
            {
              "protocol": "dns",
              "outbound": "dns-out"
            },
            {
              "geosite": "cn",
              "geoip": ["private", "cn"],
              "outbound": "direct"
            },
            {
              "geosite": "category-ads-all",
              "outbound": "block"
            }
          ],
          "auto_detect_interface": true
        }
      }
    '';
    owner = "nobody";
  };
  systemd.services.sing-box = {
    enable = true;
    description = "Sing-box networking service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.sing-box}/bin/sing-box run -c ${config.sops.templates."sing-box.json".path}";
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      User = "nobody";
      Group = "nobody";
      WorkingDirectory = "/tmp";
      Restart = "on-failure";
    };
  };
  systemd.network.wait-online = {
    anyInterface = true;
    ignoredInterfaces = [ "sing0" ];
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  sops = {
    defaultSopsFile = ./secrets.yaml;
    # see Mic92/sops-nix#167 for setting up with impermanence
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];
    secrets = {
      "iwd.ChinaNet-sun" = { };
      "users.sun.hashedPassword".neededForUsers = true;
      "sing-box.outbounds.default" = { };
    };
  };

  users.users.sun = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
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
    vim
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
      "/var/lib/bluetooth"
    ];
    users.sun = {
      directories = [
        ".cache"
        ".config"
        ".local"
        ".vscode"
        "Documents"
        "Downloads"
        "Projects"
        { directory = ".ssh"; mode = "0700"; }
        { directory = ".gnupg"; mode = "0700"; }
      ];
    };
  };

  nix.settings = {
    trusted-users = [ "root" "sun" ];
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
    use-cgroups = true;
  };
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system.stateVersion = "23.11";
}
