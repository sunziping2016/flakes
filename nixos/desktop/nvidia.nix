{ pkgs, ... }:
{
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;

    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  # services.xserver.videoDrivers = [ "nvidia" ];


  # hardware.nvidia = {
  #   modesetting.enable = true;

  #   open = false;
  #   nvidiaSettings = true;
  # };

  # virtualisation.podman.enableNvidia = true;
}
