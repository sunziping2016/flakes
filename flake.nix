{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
  };

  # TODO(layout): use submodule by directories, see <https://github.com/Misterio77/nix-starter-configs/tree/main>
  outputs = { flake-parts, nixpkgs, home-manager, impermanence, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        nixosConfigurations = {
          desktop = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./configuration.nix
              # For options, see <https://mipmip.github.io/home-manager-option-search/>
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.sun = import ./home.nix;
                home-manager.extraSpecialArgs = { inherit inputs; };
              }
              impermanence.nixosModules.impermanence
            ];
          };
        };
      };
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { pkgs, ... }: {
        legacyPackages = pkgs;
      };
    };
}
