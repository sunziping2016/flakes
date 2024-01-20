provider "authentik" {
  url   = "https://auth.szp15.com/"
  token = local.nixos_secrets["authentik.token"]
}

module "authentik_flow_ldap" {
  source = "./modules/authentik_flow_ldap"
}

data "authentik_certificate_key_pair" "this" {
  name              = "auth.szp15.com"
  fetch_certificate = false
  fetch_key         = false
}

module "authentik_provider_hydra" {
  source         = "./modules/authentik_provider_ldap"
  name           = "Hydra"
  base_dn        = "ou=hydra,dc=ldap,dc=szp,dc=io"
  flow_id        = module.authentik_flow_ldap.id
  certificate_id = data.authentik_certificate_key_pair.this.id
  ldap_username  = "hydra-ldap-service"
  ldap_password  = local.nixos_secrets["hydra.ldap.password"]
}
// Bind DN   cn=hydra-ldap-service,ou=users,ou=hydra,DC=ldap,DC=szp,DC=io
// Base DN   ou=hydra,DC=ldap,DC=szp,DC=io
// Group     memberOf=cn=Hydra Users,ou=groups,ou=hydra,dc=ldap,dc=szp,dc=io

module "authentik_application_hydra" {
  source            = "./modules/authentik_application"
  name              = "Hydra"
  slug              = "hydra"
  protocol_provider = module.authentik_provider_hydra.id
  users = [
    module.authentik_provider_hydra.user_id,
  ]
}

resource "authentik_outpost" "ldap" {
  name = "ldap"
  type = "ldap"
  protocol_providers = [
    module.authentik_provider_hydra.id
  ]
  config = jsonencode({
    log_level      = "info"
    authentik_host = "https://auth.szp15.com/"
  })
}
