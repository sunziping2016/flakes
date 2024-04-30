terraform {
  required_providers {
    keycloak = {
      source = "registry.terraform.io/mrparkers/keycloak"
    }
    sops = {
      source = "registry.terraform.io/carlpett/sops"
    }
  }
}
