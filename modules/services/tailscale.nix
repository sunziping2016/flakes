{ lib, config, ... }:
with lib;
let
  cfg = config.my-services.tailscale;
in
{
  options.my-services.tailscale = {
    enable = mkEnableOption "Enable Tailscale server";
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
    };
  };
}
