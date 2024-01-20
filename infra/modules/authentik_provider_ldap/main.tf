terraform {
  required_providers {
    authentik = {
      source = "registry.terraform.io/goauthentik/authentik"
    }
  }
}

resource "authentik_user" "this" {
  username = var.ldap_username
  name     = "${var.name} LDAP Service"
  type     = "service_account"
  password = var.ldap_password
  path     = "szp.io/service-accounts"
}

resource "authentik_group" "this" {
  name  = "${var.name} LDAP Users"
  users = [authentik_user.this.id]
}

resource "authentik_provider_ldap" "this" {
  name         = "${var.name} LDAP"
  base_dn      = var.base_dn
  bind_flow    = var.flow_id
  bind_mode    = "cached"
  search_mode  = "cached"
  search_group = authentik_group.this.id
  certificate  = var.certificate_id
}
