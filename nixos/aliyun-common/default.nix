{ self, inputs, ... }:
{
  imports = [
    ../aliyun-common/disko.nix
    ./configuration.nix
    self.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
  ];
}
