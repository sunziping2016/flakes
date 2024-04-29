{ lib, config, pkgs, ... }:
with lib;
let
  root = ./minecraft;

  fetchLocalPackwizModpack =
    { root
    , ...
    }@args:
    (pkgs.fetchPackwizModpack ({ url = ""; } // args)).overrideAttrs (old: {
      buildInputs = with pkgs; [ jre_headless jq moreutils ];
      buildPhase = ''
        java -jar "$packwizInstallerBootstrap" \
          --bootstrap-main-jar "$packwizInstaller" \
          --bootstrap-no-update \
          --no-gui \
          --side "server" \
          "${root}/pack.toml"
      '';
      passthru = old.passthru // {
        manifest = lib.importTOML "${root}/pack.toml";
      };
    });

  cfg = config.my-services.minecraft-server;
  modpack = fetchLocalPackwizModpack {
    packHash = "sha256-RV26YPW2qLwYGeD9LADN+vle6UJHvV2iEP4WbljNXX0=";
    inherit root;
  };
  mcVersion = modpack.manifest.versions.minecraft;
  fabricVersion = modpack.manifest.versions.fabric;
  serverVersion = lib.replaceStrings [ "." ] [ "_" ] "fabric-${mcVersion}";

  opts = builtins.fromTOML (builtins.readFile ./minecraft.toml);
in
{
  options.my-services.minecraft-server = {
    enable = mkEnableOption "Enable Minecraft Fabric Server";
  };

  config = mkIf cfg.enable {
    services.minecraft-servers = {
      enable = true;
      eula = true;
    };

    environment.persistence."/persist" = {
      directories = [
        {
          directory = config.services.minecraft-servers.dataDir;
          user = "minecraft";
          group = "minecraft";
        }
      ];
    };

    users.users.minecraft.uid = config.ids.uids.minecraft;
    users.groups.minecraft.gid = config.ids.gids.minecraft;

    services.minecraft-servers.servers.default = {
      # /gamerule playersSleepingPercentage 0
      # /carpet setDefault defaultLoggers mobcaps,tps
      enable = true;
      package = pkgs.fabricServers.${serverVersion}.override { loaderVersion = fabricVersion; };
      serverProperties = {
        difficulty = "hard";
        gamemode = "survival";
        motd = ''\u00A7e\u00A7oZiping Sun's\u00A7r Minecraft Server\u00A7r\n\u00A72\u00A7lHappy \u00A7kCrafting!'';
        white-list = true;
      };
      whitelist = lib.listToAttrs (lib.lists.map (x: { name = x.name; value = x.id; }) opts.users);
      symlinks = {
        "mods" = "${modpack}/mods";
        "dynmap/configuration.txt" = "${root}/dynmap/configuration.txt";
      };
    };

    # dynmap
    services.nginx.enable = true;
    services.nginx.virtualHosts."map.szp15.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:25567";
    };
  };
}
