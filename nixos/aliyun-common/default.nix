{ self, inputs, ... }:
{
  imports = [
    ../aliyun-common/disko.nix
    ./configuration.nix
    self.nixosModules.ng
    inputs.impermanence.nixosModules.impermanence
  ];
}
