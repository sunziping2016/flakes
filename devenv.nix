{ pkgs, config, ... }:
let
  my-opentofu = pkgs.opentofu.withPlugins (ps: with ps; [
    sops
    alicloud
    authentik
    ldap
  ]);
in
{
  # This is your devenv configuration
  packages = with pkgs; [
    colmena
    fzf # for just
    just
    my-opentofu
    nix-update
    sops
    jq
  ];
  pre-commit.hooks.nixpkgs-fmt.enable = true;
  pre-commit.hooks.my-opentofu-fmt = {
    enable = true;
    name = "opentofu-fmt";
    entry = "${my-opentofu}/bin/tofu fmt";
    files = "\\.tf$";
  };
  pre-commit.hooks.pre-commit-hook-ensure-sops = {
    enable = true;
    # FIXME: doesn't support env file
    files = "secrets\\.(yaml|json)$";
  };
  pre-commit.hooks.just-fmt =
    let
      script = with pkgs; writeShellScript "just-fmt" ''
        for file in "$@"; do
          ${pkgs.just}/bin/just --fmt --unstable -f "$file";
        done
      '';
    in
    {
      enable = true;
      entry = "${script}";
      files = "justfile$";
    };
}
