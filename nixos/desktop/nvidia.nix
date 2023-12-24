{ ... }:
{
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];


  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement.enable = true;

    open = false;
    nvidiaSettings = true;

    prime = {
      sync.enable = true;

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
