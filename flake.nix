{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
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
  };
  outputs = { self, flake-utils, nixpkgs, devenv, ... }@inputs:
    let
      lib = nixpkgs.lib;
      modules = import ./modules;

      data = lib.importJSON ./infra/data.json;
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
            ];
          };
        };
      } //
      (
        # nix run github:numtide/nixos-anywhere -- --flake .#aliyun-hz0 root@hz0.szp15.com \
        #     --kexec path/to/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz --no-substitute-on-destination
        lib.mapAttrs
          (
            name: node: {
              deployment = {
                targetHost = "${node.fqdn}";
                tags = node.tags;
              };
              imports = [ ./nixos/${name} ];
            }
          )
          data.nodes.value
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
      overlays.default = this.overlay;
      nixosConfigurations =
        {
          desktop = import ./nixos/desktop {
            system = "x86_64-linux";
            inherit self inputs;
          };
        } //
        self.colmenaHive.nodes;
      colmenaHive = inputs.colmena.lib.makeHive hive;
    };
}
