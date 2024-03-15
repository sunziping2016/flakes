module "security_group_hz" {
  source = "../../modules/aliyun_security_group"
  vpc_id = module.vpc_hz.vpc_id
  rules = {
    icmp       = { ip_protocol = "icmp", cidr_ip = "0.0.0.0/0" }
    ssh_ipv4   = { port_range = "22/22", cidr_ip = "0.0.0.0/0" }
    ssh_ipv6   = { port_range = "22/22", ipv6_cidr_ip = "::/0" }
    http_ipv4  = { port_range = "80/80", cidr_ip = "0.0.0.0/0" }
    http_ipv6  = { port_range = "80/80", ipv6_cidr_ip = "::/0" }
    https_ipv4 = { port_range = "443/443", cidr_ip = "0.0.0.0/0" }
    https_ipv6 = { port_range = "443/443", ipv6_cidr_ip = "::/0" }
    ldaps_ipv4 = { port_range = "636/636", cidr_ip = "0.0.0.0/0" }
    ldaps_ipv6 = { port_range = "636/636", ipv6_cidr_ip = "::/0" }
  }
}

resource "alicloud_instance" "hz0" {
  force_delete         = true
  availability_zone    = "cn-hangzhou-h"
  security_groups      = [module.security_group_hz.id]
  image_id             = "ubuntu_22_04_uefi_x64_20G_alibase_20230515.vhd"
  instance_type        = "ecs.e-c1m4.large"
  instance_charge_type = "PrePaid"
  vswitch_id           = module.vpc_hz.vswhitch_ids.h
  key_name             = "cardno:19_795_283"
  ipv6_address_count   = 1
}

resource "alicloud_instance" "hz1" {
  force_delete         = true
  availability_zone    = "cn-hangzhou-h"
  security_groups      = [module.security_group_hz.id]
  image_id             = "ubuntu_22_04_uefi_x64_20G_alibase_20230515.vhd"
  instance_type        = "ecs.e-c1m1.large"
  instance_charge_type = "PrePaid"
  vswitch_id           = module.vpc_hz.vswhitch_ids.h
  key_name             = "cardno:19_795_283"
  ipv6_address_count   = 1
  renewal_status       = "AutoRenewal"
  auto_renew_period    = 12
}

locals {
  nodes = [
    {
      hostname    = "aliyun-hz0"
      ssh         = { host = "hz0.szp15.com" }
      arch        = "x86_64"
      init_config = "aliyun-common"
    },
    {
      hostname    = "aliyun-hz1"
      ssh         = { host = "hz1.szp15.com" }
      arch        = "x86_64"
      init_config = "aliyun-common"
    }
  ]
}

resource "local_file" "nodes" {
  content  = jsonencode(local.nodes)
  filename = "../../generated/nodes.json"
}
