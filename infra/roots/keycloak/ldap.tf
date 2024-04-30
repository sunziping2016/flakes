resource "keycloak_ldap_user_federation" "this" {
  name                    = "openldap"
  realm_id                = "master"
  users_dn                = "ou=users,dc=szp,dc=io"
  connection_url          = "ldap://localhost"
  username_ldap_attribute = "uid"
  rdn_ldap_attribute      = "uid"
  uuid_ldap_attribute     = "entryUUID"
  user_object_classes = [
    "inetOrgPerson",
    "organizationalPerson",
    "person",
    "top"
  ]
  bind_dn             = "cn=admin,dc=szp,dc=io"
  bind_credential     = var.ldap_bind_credential
  changed_sync_period = 86400
  edit_mode           = "WRITABLE"
  pagination          = true
  search_scope        = "ONE_LEVEL"
  sync_registrations  = true
  # TODO: tls
  use_truststore_spi              = "ALWAYS"
  vendor                          = "OTHER"
  use_password_modify_extended_op = true
  delete_default_mappers          = true
}

resource "keycloak_ldap_group_mapper" "this" {
  realm_id                  = keycloak_ldap_user_federation.this.realm_id
  ldap_user_federation_id   = keycloak_ldap_user_federation.this.id
  name                      = "group-mapper"
  ldap_groups_dn            = "ou=groups,dc=szp,dc=io"
  group_name_ldap_attribute = "cn"
  group_object_classes = [
    "groupOfNames"
  ]
  membership_attribute_type            = "DN"
  membership_ldap_attribute            = "member"
  membership_user_ldap_attribute       = "cn"
  memberof_ldap_attribute              = "memberOf"
  preserve_group_inheritance           = true
  mode                                 = "LDAP_ONLY"
  drop_non_existing_groups_during_sync = true
}


resource "keycloak_ldap_user_attribute_mapper" "username" {
  realm_id                = keycloak_ldap_user_federation.this.realm_id
  ldap_user_federation_id = keycloak_ldap_user_federation.this.id
  name                    = "username"

  user_model_attribute = "username"
  ldap_attribute       = "uid"
  is_mandatory_in_ldap = true
}

resource "keycloak_ldap_user_attribute_mapper" "create_date" {
  realm_id                = keycloak_ldap_user_federation.this.realm_id
  ldap_user_federation_id = keycloak_ldap_user_federation.this.id
  name                    = "create-date"

  user_model_attribute        = "createTimestamp"
  ldap_attribute              = "createTimestamp"
  read_only                   = true
  always_read_value_from_ldap = true
}

resource "keycloak_ldap_user_attribute_mapper" "modify_date" {
  realm_id                = keycloak_ldap_user_federation.this.realm_id
  ldap_user_federation_id = keycloak_ldap_user_federation.this.id
  name                    = "modify-date"

  user_model_attribute        = "modifyTimestamp"
  ldap_attribute              = "modifyTimestamp"
  read_only                   = true
  always_read_value_from_ldap = true
}


resource "keycloak_ldap_user_attribute_mapper" "first_name" {
  realm_id                = keycloak_ldap_user_federation.this.realm_id
  ldap_user_federation_id = keycloak_ldap_user_federation.this.id
  name                    = "first-name"

  user_model_attribute = "firstName"
  ldap_attribute       = "givenName"
  is_mandatory_in_ldap = true
}

resource "keycloak_ldap_user_attribute_mapper" "last_name" {
  realm_id                = keycloak_ldap_user_federation.this.realm_id
  ldap_user_federation_id = keycloak_ldap_user_federation.this.id
  name                    = "last-name"

  user_model_attribute = "lastName"
  ldap_attribute       = "sn"
  is_mandatory_in_ldap = true
}

resource "keycloak_ldap_full_name_mapper" "this" {
  realm_id                = keycloak_ldap_user_federation.this.realm_id
  ldap_user_federation_id = keycloak_ldap_user_federation.this.id
  name                    = "full-name"

  ldap_full_name_attribute = "cn"
}

resource "keycloak_ldap_user_attribute_mapper" "email" {
  realm_id                = keycloak_ldap_user_federation.this.realm_id
  ldap_user_federation_id = keycloak_ldap_user_federation.this.id
  name                    = "email"

  user_model_attribute = "email"
  ldap_attribute       = "mail"
  is_mandatory_in_ldap = true
}
