{ ... }: {
  programs.git = {
    enable = true;
    userName = "Ziping Sun";
    userEmail = "me@szp.io";
  };

  programs.fish.enable = true;

  programs.gpg.enable = true;

  home.stateVersion = "23.11";
}
