# see https://goauthentik.io/docs/providers/ldap/generic_setup
terraform {
  required_providers {
    authentik = {
      source = "registry.terraform.io/goauthentik/authentik"
    }
  }
}

resource "authentik_stage_identification" "this" {
  name           = "ldap-identification-stage"
  user_fields    = ["username", "email"]
  password_stage = authentik_stage_password.this.id
}

resource "authentik_stage_password" "this" {
  name = "ldap-authentication-password"
  backends = [
    "authentik.core.auth.InbuiltBackend",
    "authentik.core.auth.TokenBackend",
    "authentik.sources.ldap.auth.LDAPBackend",
  ]
}

resource "authentik_stage_user_login" "this" {
  name = "ldap-authentication-login"
}

resource "authentik_flow" "this" {
  name        = "ldap-authentication-flow"
  title       = "ldap-authentication-flow"
  slug        = "ldap-authentication-flow"
  designation = "authentication"
}

resource "authentik_flow_stage_binding" "ldap_identification_stage" {
  target = authentik_flow.this.uuid
  stage  = authentik_stage_identification.this.id
  order  = 10
}

resource "authentik_flow_stage_binding" "ldap_authentication_login" {
  target = authentik_flow.this.uuid
  stage  = authentik_stage_user_login.this.id
  order  = 30
}
