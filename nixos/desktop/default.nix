{ system, inputs }:
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ./configuration.nix
    # For options, see <https://mipmip.github.io/home-manager-option-search/>
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.sun = import ./home.nix;
      home-manager.extraSpecialArgs = { inherit inputs; };
    }
    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops
  ];
  specialArgs = {
    inherit inputs;
  };
}
