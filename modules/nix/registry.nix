{ self, inputs, ... }:
{
  # register this flake in the registry
  nix.registry.p.flake = self;

  # disable the default flake registry (https://github.com/NixOS/flake-registry)
  nix.settings.flake-registry = "/etc/nix/registry.json";

  # for impure evaluation, use the nixpkgs in this flake
  nix.settings.nix-path = [ "nixpkgs=${inputs.nixpkgs}" ];
}
