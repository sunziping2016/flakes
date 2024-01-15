provider "authentik" {
  url   = "https://auth.szp15.com/"
  token = local.nixos_secrets["authentik.token"]
}

data "authentik_users" "all" {
}
