terraform {
  required_providers {
    alicloud = {
      source = "registry.terraform.io/aliyun/alicloud"
    }
  }
}

resource "alicloud_nat_gateway" "this" {
  vpc_id               = var.vpc_id
  vswitch_id           = var.vswitch_id
  nat_type             = "Enhanced"
  payment_type         = "PayAsYouGo"
  internet_charge_type = "PayByLcu"
}

resource "alicloud_eip_address" "this" {
  bandwidth            = 200
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_eip_association" "this" {
  allocation_id = alicloud_eip_address.this.id
  instance_id   = alicloud_nat_gateway.this.id
}

resource "alicloud_forward_entry" "this" {
  for_each         = var.forward_entries
  forward_table_id = alicloud_nat_gateway.this.forward_table_ids
  ip_protocol      = each.value.ip_protocol
  external_port    = each.value.external_port
  internal_port    = each.value.internal_port
  external_ip      = alicloud_eip_address.this.ip_address
  internal_ip      = each.value.internal_ip
}

resource "alicloud_snat_entry" "this" {
  snat_table_id     = alicloud_nat_gateway.this.snat_table_ids
  source_vswitch_id = var.vswitch_id
  snat_ip           = alicloud_eip_address.this.ip_address
}
