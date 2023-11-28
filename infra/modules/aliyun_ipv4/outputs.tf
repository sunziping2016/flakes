output "ip_addresses" {
  value = { for k, v in alicloud_eip_address.this : k => v.ip_address }
}
