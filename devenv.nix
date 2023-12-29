{ pkgs, config, ... }:
let
  my-opentofu = pkgs.opentofu.withPlugins (ps: with ps; [ sops alicloud ]);
in
{
  # This is your devenv configuration
  packages = with pkgs; [
    colmena
    my-opentofu
    sops
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
    entry = "${pkgs.pre-commit-hook-ensure-sops}/bin/pre-commit-hook-ensure-sops";
    files = "secrets\\.(yaml|json)$";
  };
  pre-commit.hooks.terraform-tfstate-ensure-sops =
    let
      script = with pkgs; writeShellScript "terraform-tfstate-ensure-sops" ''
        ${sops}/bin/sops --decrypt --output-type binary infra/terraform.tfstate.secrets.json | ${diffutils}/bin/diff -q - infra/terraform.tfstate
      '';
    in
    {
      enable = true;
      description = "Terraform tfstate encryption checker.";
      entry = "${script}";
      pass_filenames = false;
      raw.always_run = true;
    };
}
