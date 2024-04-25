{
  nixosModules.default = import ./default;
  nixosModules.ng = { inputs, ... }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
      inputs.arion.nixosModules.arion
      inputs.nix-minecraft.nixosModules.minecraft-servers
      # unconditional config
      ./nix/settings.nix
      ./nix/registry.nix
      ./networking/systemd.nix
      ./services/nginx.nix
      ./misc/ids.nix
      ./misc/ports.nix
      # optional config
      ./services/sing-box.nix
      ./services/minecraft.nix
      ./services/openldap.nix
      ./services/headscale.nix
      ./services/tailscale.nix
      ./virtualization/arion.nix
    ];

    my-services.tailscale.enable = true;
  };
  homeManagerModules.nvim = import ./nvim;
}
