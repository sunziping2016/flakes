terraform {
  required_providers {
    alicloud = {
      source = "registry.terraform.io/aliyun/alicloud"
    }
  }
}

resource "alicloud_vpc_ipv6_gateway" "this" {
  vpc_id = var.vpc_id
}

data "alicloud_vpc_ipv6_addresses" "this" {
  for_each               = var.instance_ids
  associated_instance_id = each.value
  status                 = "Available"
}

resource "alicloud_vpc_ipv6_internet_bandwidth" "this" {
  for_each             = var.instance_ids
  ipv6_address_id      = data.alicloud_vpc_ipv6_addresses.this[each.key].addresses[0].id
  ipv6_gateway_id      = alicloud_vpc_ipv6_gateway.this.id
  internet_charge_type = "PayByTraffic"
  bandwidth            = 1000
}
