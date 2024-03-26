{
  nixosModules.default = import ./default;
  nixosModules.ng = { inputs, ... }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
      # setup nix
      ./nix/settings.nix
      ./nix/registry.nix
      # use systemd for network
      ./networking/systemd.nix
      #### config ####
      # uid & gid
      ./misc/ids.nix
      #### services ####
      ./services/sing-box.nix
      ./services/minecraft.nix
      ./services/nginx.nix
    ];

    my-services.sing-box.enable = true;
  };
  homeManagerModules.nvim = import ./nvim;
}
