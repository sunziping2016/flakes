output "id" {
  value = alicloud_nat_gateway.this.id
}

output "ip_address" {
  value = alicloud_eip_address.this.ip_address
}
