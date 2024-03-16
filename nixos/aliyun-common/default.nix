{ self, inputs, ... }:
{
  imports = [
    ./disko.nix
    ./configuration.nix
    self.nixosModules.ng
    inputs.impermanence.nixosModules.impermanence
  ];
}
