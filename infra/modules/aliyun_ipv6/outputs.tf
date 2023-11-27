output "ipv6_addresses" {
  value = { for k, v in data.alicloud_vpc_ipv6_addresses.this : k => v.addresses[0].ipv6_address }
}
