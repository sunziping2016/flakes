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
      # proxy
      ./networking/sing-box.nix
    ];

    networking.sing-box.enable = true;
  };
  homeManagerModules.nvim = import ./nvim;
}
