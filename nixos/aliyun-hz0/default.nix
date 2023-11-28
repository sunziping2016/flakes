{ inputs, ... }:
{
  imports = [
    ./disko.nix
    ./configuration.nix
    inputs.impermanence.nixosModules.impermanence
  ];
}
