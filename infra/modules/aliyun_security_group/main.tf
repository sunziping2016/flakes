terraform {
  required_providers {
    alicloud = {
      source = "registry.terraform.io/aliyun/alicloud"
    }
  }
}

resource "alicloud_security_group" "this" {
  description = "OpenTofu security group"
  vpc_id      = var.vpc_id
}

resource "alicloud_security_group_rule" "this" {
  for_each          = var.rules
  type              = each.value.type
  ip_protocol       = each.value.ip_protocol
  port_range        = each.value.port_range
  cidr_ip           = each.value.cidr_ip
  ipv6_cidr_ip      = each.value.ipv6_cidr_ip
  nic_type          = "intranet"
  security_group_id = alicloud_security_group.this.id
}
