data "sops_file" "secrets" {
  source_file = "secrets.enc.yaml"
}

locals {
  secrets = yamldecode(data.sops_file.secrets.raw)
}
