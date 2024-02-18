terraform {
  required_providers {
    alicloud = {
      source = "registry.terraform.io/aliyun/alicloud"
    }
  }
}

resource "alicloud_vpc" "this" {
  cidr_block  = var.cidr_block
  enable_ipv6 = true
}

resource "alicloud_vswitch" "this" {
  for_each             = var.vswitches
  vpc_id               = alicloud_vpc.this.id
  zone_id              = each.value.zone_id
  enable_ipv6          = true
  cidr_block           = cidrsubnet(alicloud_vpc.this.cidr_block, 12, each.value.netnum)
  ipv6_cidr_block_mask = 64
}
