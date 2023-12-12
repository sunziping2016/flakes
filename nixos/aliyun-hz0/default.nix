{ self, inputs, ... }:
{
  imports = [
    ./disko.nix
    ./configuration.nix
    self.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops
  ];
}
