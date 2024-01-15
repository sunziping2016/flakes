data "sops_file" "secrets" {
  source_file = "secrets.yaml"
}

data "sops_file" "nixos_secrets" {
  source_file = "../nixos/secrets.yaml"
}

locals {
  secrets       = yamldecode(data.sops_file.secrets.raw)
  nixos_secrets = yamldecode(data.sops_file.nixos_secrets.raw)
}
