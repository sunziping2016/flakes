{ inputs, lib, config, pkgs, ... }:
with lib;
let
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
  modpack = fetchLocalPackwizModpack rec {
    root = ./minecraft;
    packHash = "sha256-HkHtz6TWIM1k8TfOrJKrn0lSSNg4KasXJjc9HSdS5+A=";
  };
  mcVersion = modpack.manifest.versions.minecraft;
  fabricVersion = modpack.manifest.versions.fabric;
  serverVersion = lib.replaceStrings [ "." ] [ "_" ] "fabric-${mcVersion}";
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];


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
      enable = true;
      package = pkgs.fabricServers.${serverVersion}.override { loaderVersion = fabricVersion; };
      serverProperties = {
        difficulty = "hard";
        gamemode = "survival";
        motd = ''\u00A7e\u00A7oZiping Sun's\u00A7r Minecraft Server\u00A7r\n\u00A72\u00A7lHappy \u00A7kCrafting!'';
        white-list = true;
      };
      whitelist = {
        "aaaaaaaqie" = "fc50c689-79e1-46d1-87b0-63b7234eacb7";
        "sunziping2016" = "78b7406b-834b-42a7-948a-0a8087b6932e";
        "Forev3rNAlway5" = "cc64d967-bf1f-43a8-bbee-2eaaf4b332e5";
      };
      symlinks = {
        "mods" = "${modpack}/mods";
        "dynmap/configuration.txt" = "${modpack}/dynmap/configuration.txt";
      };
    };
  };
}
