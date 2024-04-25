# from https://github.com/linyinfeng/dotfiles/blob/main/nixos/modules/misc/ports.nix
{ config, lib, ... }:
{
  options.ports = lib.mkOption {
    type = with lib.types; attrsOf port;
    default = { };
  };

  config = {
    assertions = [
      {
        assertion =
          let
            vals = lib.attrValues config.ports;
            noCollision = l: lib.length (lib.unique l) == lib.length l;
          in
          noCollision vals;
        message = "ports collision";
      }
    ];

    ports = {
      minecraft = 25565;
      minecraft-map = 25567;
      wireguard = 51820;
      headscale = 30000;
    };
  };
}
