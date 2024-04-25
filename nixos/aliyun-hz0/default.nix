{ self, inputs, ... }:
{
  imports = [
    ../aliyun-common
  ];

  my-services.minecraft-server.enable = true;
  my-services.headscale.enable = true;
}
