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
  };
  outputs = { self, flake-utils, nixpkgs, ... }@inputs:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ]
      (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          legacyPackages = pkgs;
          devShells.default = with pkgs; mkShell {
            nativeBuildInputs = [
              colmena
            ];
          };
        }
      ) // {
      nixosConfigurations = {
        desktop = import ./nixos/desktop {
          system = "x86_64-linux";
          inherit self inputs;
        };
      } // self.colmenaHive.nodes;
      colmenaHive = inputs.colmena.lib.makeHive {
        meta = {
          specialArgs = {
            inherit self inputs;
            data.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAamaMcCAc7DhTJjDqBwXTWhewX0OI8vAuXLvc17yqK/"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIO4wL3BzfaMDOpbT/U/99MVQERjtzH2YxA6KAs7lwM"
            ];
          };
          nixpkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
          };
        };

        # nix run github:numtide/nixos-anywhere -- --flake .#aliyun-hz0 root@sh1.szp15.com \
        #     --kexec path/to/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz --no-substitute-on-destination
        aliyun-hz0 = {
          deployment = {
            targetHost = "sh1.szp15.com";
            tags = [ "aliyun" ];
          };
          imports = [ ./nixos/aliyun-hz0 ];
        };
      };
    };
}
