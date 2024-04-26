{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.stable.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-images = {
      url = "github:nix-community/nixos-images";
      inputs.nixos-unstable.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    dream2nix = {
      url = "github:nix-community/dream2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, flake-utils, nixpkgs, devenv, dream2nix, ... }@inputs:
    let
      lib = nixpkgs.lib;
      modules = import ./modules;

      hive = {
        meta = {
          specialArgs = {
            inherit self inputs;
            data.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAamaMcCAc7DhTJjDqBwXTWhewX0OI8vAuXLvc17yqK/"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIO4wL3BzfaMDOpbT/U/99MVQERjtzH2YxA6KAs7lwM"
            ];
          };
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [
              self.overlays.default
              inputs.colmena.overlay
              inputs.nix-minecraft.overlay
            ];
          };
        };
      } //
      (
        lib.pipe (lib.importJSON ./infra/generated/nodes.json) [
          (lib.lists.map (node:
            lib.nameValuePair node.hostname {
              deployment = {
                targetHost = node.ssh.host or null;
                targetUser = node.ssh.user or "root";
                targetPort = node.ssh.port or null;
              };

              imports = [ ./nixos/${node.config or node.hostname} ];
              nixpkgs.system = "${node.arch}-linux";
              networking.hostName = node.hostname;
            }
          ))
          lib.listToAttrs
        ]
      );

      this = import ./pkgs;
    in
    (
      flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ]
        (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                self.overlays.default
                inputs.colmena.overlay
                inputs.nix-minecraft.overlay
              ];
            };
          in
          rec {
            legacyPackages = pkgs;
            devShells.default = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                ./devenv.nix
              ];
            };
            packages = {
              devenv-up = devShells.default.config.procfileScript;
              kexec-installer-nixos-unstable-noninteractive = inputs.nixos-images.packages.${system}.kexec-installer-nixos-unstable-noninteractive;
              nixos-anywhere = inputs.nixos-anywhere.packages.${system}.nixos-anywhere;
            } // this.packages pkgs;
          }
        )
    ) //
    {
      hydraJobs = {
        desktop = self.nixosConfigurations.desktop.config.system.build.toplevel;
      };
      nixosModules = modules.nixosModules;
      homeManagerModules = modules.homeManagerModules;
      overlays.default = lib.composeExtensions this.overlay (self: super:
        dream2nix.lib.importPackages {
          projectRoot = ./.;
          projectRootFile = "flake.nix";
          packagesDir = ./dream-pkgs;
          packageSets.nixpkgs = super;
        }
      );
      nixosConfigurations =
        {
          desktop = import ./nixos/desktop {
            system = "x86_64-linux";
            hostname = "desktop";
            inherit self inputs;
          };
        } //
        self.colmenaHive.nodes;
      colmenaHive = inputs.colmena.lib.makeHive hive;
    };
}
