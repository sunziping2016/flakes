terraform {
  required_providers {
    alicloud = {
      source = "registry.terraform.io/aliyun/alicloud"
    }
  }
}

resource "alicloud_vpc_ipv4_gateway" "this" {
  vpc_id = var.vpc_id
}

resource "alicloud_route_table" "this" {
  vpc_id         = var.vpc_id
  associate_type = "Gateway"
}

resource "alicloud_vpc_gateway_route_table_attachment" "this" {
  ipv4_gateway_id = alicloud_vpc_ipv4_gateway.this.id
  route_table_id  = alicloud_route_table.this.id
}

resource "alicloud_route_entry" "this" {
  route_table_id        = var.vpc_route_table_id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "Ipv4Gateway"
  nexthop_id            = alicloud_vpc_ipv4_gateway.this.id
}

resource "alicloud_eip_address" "this" {
  for_each             = var.instance_ids
  bandwidth            = 200
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_eip_association" "source" {
  for_each      = var.instance_ids
  allocation_id = alicloud_eip_address.this[each.key].id
  instance_id   = each.value
}
