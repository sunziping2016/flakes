{ self, inputs, ... }:
{
  imports = [
    ./disko.nix
    ./configuration.nix
    self.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
  ];
}
