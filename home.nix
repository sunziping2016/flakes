{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "Ziping Sun";
    userEmail = "me@szp.io";
    extraConfig = {
      commit.gpgSign = true;
      init.defaultBranch = "master";
    };
  };

  programs.fish.enable = true;
  programs.gpg.enable = true;
  services.gpg-agent.enable = true;
  programs.vscode.enable = true;

  home.packages = with pkgs; [
    _1password-gui
    microsoft-edge
  ];

  xdg = {
    enable = true;
    userDirs.enable = true;
  };

  home.stateVersion = "23.11";
}
