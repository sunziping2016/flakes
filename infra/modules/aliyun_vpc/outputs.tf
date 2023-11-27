output "vpc_id" {
  value = alicloud_vpc.this.id
}

output "vswhitch_ids" {
  value = { for k, v in alicloud_vswitch.this : k => v.id }
}
