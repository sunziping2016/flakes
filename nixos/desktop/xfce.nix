{ pkgs, ... }:
{
  # see https://gist.github.com/nat-418/1101881371c9a7b419ba5f944a7118b0
  environment = {
    systemPackages = with pkgs; [
      # graphics application
      birdtray
      blueman
      firefox
      gimp-with-plugins
      evince
      foliate
      font-manager
      gnome.file-roller
      gnome.gnome-disk-utility
      inkscape-with-extensions
      libqalculate
      pavucontrol
      qalculate-gtk
      remmina
      telegram-desktop
      thunderbird
      wpsoffice
      xclip
      xcolor
      xfce.catfish
      xfce.gigolo
      xfce.orage
      xfce.xfburn
      xfce.xfce4-appfinder
      xfce.xfce4-dict
      xfce.xfdashboard
      xorg.xkill
      # xfce plugins
      xfce.xfce4-pulseaudio-plugin
      xfce.xfce4-systemload-plugin
      xfce.xfce4-weather-plugin
      xfce.xfce4-whiskermenu-plugin
    ];
  };
}
