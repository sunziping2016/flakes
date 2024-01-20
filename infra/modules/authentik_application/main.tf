terraform {
  required_providers {
    authentik = {
      source = "registry.terraform.io/goauthentik/authentik"
    }
  }
}

resource "authentik_application" "this" {
  name              = var.name
  slug              = var.slug
  protocol_provider = var.protocol_provider
}

resource "authentik_group" "this" {
  name  = "${var.name} Users"
  users = var.users
}

resource "authentik_policy_binding" "this" {
  target = authentik_application.this.uuid
  group  = authentik_group.this.id
  order  = 0
}
