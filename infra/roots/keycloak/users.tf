resource "keycloak_user" "ziping_sun" {
  realm_id   = "master"
  username   = "ziping_sun"
  enabled    = true
  email      = "me@szp.io"
  first_name = "Ziping"
  last_name  = "Sun"
  initial_password {
    value     = "changeme"
    temporary = true
  }
  attributes = {}

  lifecycle {
    ignore_changes = [
      attributes["LDAP_ENTRY_DN"],
      attributes["LDAP_ID"],
      attributes["createTimestamp"],
      attributes["modifyTimestamp"],
    ]
  }
}
