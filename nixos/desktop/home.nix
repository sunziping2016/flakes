{ pkgs, self, ... }: {
  imports = [
    ./helix.nix
    self.homeManagerModules.nvim
  ];

  programs.git = {
    enable = true;
    userName = "Ziping Sun";
    userEmail = "me@szp.io";
    extraConfig = {
      commit.gpgSign = true;
      init.defaultBranch = "master";
    };
  };

  programs.fish = {
    enable = true;
    plugins = with pkgs.fishPlugins; [
      { name = "tide"; src = tide.src; }
    ];
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.gpg.enable = true;
  # xfce4-session will launch gpg=agent by default.
  # See <https://docs.xfce.org/xfce/xfce4-session/advanced> for details.
  # Use the following commands to disable it.
  # ```shell
  # xfconf-query -c xfce4-session -p /startup/ssh-agent/enabled -n -t bool -s false
  # xfconf-query -c xfce4-session -p /startup/gpg-agent/enabled -n -t bool -s false
  # ```
  services.gpg-agent = {
    enable = true;
    # Yubikey supports multiple ways for ssh authentication and commit signing.
    # See <https://www.reddit.com/r/yubikey/comments/wzwilj/which_option_to_use_openpgp_piv_fido2sk_keys/>
    # for a comparison on theses ways.
    # Keys need to be listed in sshcontrol file, or have `Use-for-ssh: yes` attribute.
    # ```shell
    # gpg-connect-agent "KEYATTR 3770D6CF9F129A7A699AECA8248F3FE0BC366A21 Use-for-ssh: yes" /bye
    # ```
    # Use `ssh-add -l` to add host keys to sshcontrol file. In this way, when the
    # card is unplugged, the host key will come before the card key.
    enableSshSupport = true;
  };
  programs.vscode.enable = true;

  home.packages = with pkgs; [
    microsoft-edge
  ];

  xdg = {
    enable = true;
    userDirs.enable = true;
  };

  home.stateVersion = "23.11";
}
