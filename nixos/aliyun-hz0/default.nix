{ self, inputs, ... }:
{
  imports = [
    ../aliyun-common
  ];

  my-services.minecraft-server.enable = true;
}
