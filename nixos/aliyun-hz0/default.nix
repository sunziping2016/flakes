{ self, inputs, ... }:
{
  imports = [
    ../aliyun-common
    # ../aliyun-common/disko.nix
    # ./configuration.nix
    # self.nixosModules.default
    # inputs.impermanence.nixosModules.impermanence
    # inputs.sops-nix.nixosModules.sops
  ];

  my-services.minecraft-server.enable = true;
}
