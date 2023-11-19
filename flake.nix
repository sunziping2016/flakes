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
        }
      ) // {
      nixosConfigurations = {
        desktop = import ./nixos/desktop {
          system = "x86_64-linux";
          inherit self inputs;
        };
      };
    };
}
