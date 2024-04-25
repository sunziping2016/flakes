{ self, system, inputs, hostname, ... }:
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ./configuration.nix
    self.nixosModules.default
    # For options, see <https://mipmip.github.io/home-manager-option-search/>
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.sun = import ./home.nix;
      home-manager.extraSpecialArgs = { inherit self inputs; };
    }
    inputs.impermanence.nixosModules.impermanence
    { nixpkgs.overlays = [ self.overlays.default ]; }
    self.nixosModules.ng
    { networking.hostName = hostname; }
  ];
  specialArgs = { inherit self inputs; };
}
