provider "alicloud" {
  access_key = local.secrets.aliyun.access_key
  secret_key = local.secrets.aliyun.secret_key
  region     = "cn-hangzhou"
}

module "aliyun_vpc_hz" {
  source = "./modules/aliyun_vpc"
  vswitches = {
    hz_h = { zone_id = "cn-hangzhou-h", netnum = 0 }
  }
}

module "aliyun_security_group_hz" {
  source = "./modules/aliyun_security_group"
  vpc_id = module.aliyun_vpc_hz.vpc_id
  rules = {
    icmp     = { ip_protocol = "icmp", cidr_ip = "0.0.0.0/0" }
    ssh_ipv4 = { port_range = "22/22", cidr_ip = "0.0.0.0/0" }
    ssh_ipv6 = { port_range = "22/22", ipv6_cidr_ip = "::/0" }
  }
}

resource "alicloud_instance" "hz0" {
  force_delete         = true
  availability_zone    = "cn-hangzhou-h"
  security_groups      = [module.aliyun_security_group_hz.id]
  image_id             = "ubuntu_22_04_uefi_x64_20G_alibase_20230515.vhd"
  instance_type        = "ecs.t6-c1m1.large"
  system_disk_size     = 40
  instance_charge_type = "PostPaid"
  vswitch_id           = module.aliyun_vpc_hz.vswhitch_ids.hz_h
  ipv6_address_count   = 1
  key_name             = "cardno:19_795_283"
}

# module "aliyun_nat_hz" {
#   source     = "./modules/aliyun_nat"
#   vpc_id     = module.aliyun_vpc_hz.vpc_id
#   vswitch_id = module.aliyun_vpc_hz.vswhitch_ids.hz_h
#   forward_entries = {
#     ssh = { external_port = "22", internal_port = "22", internal_ip = alicloud_instance.hz0.private_ip }
#   }
# }

module "aliyun_ipv4_hz" {
  source             = "./modules/aliyun_ipv4"
  vpc_id             = module.aliyun_vpc_hz.vpc_id
  vpc_route_table_id = module.aliyun_vpc_hz.route_table_id
  instance_ids = {
    hz0 = alicloud_instance.hz0.id
  }
}

module "aliyun_ipv6_hz" {
  source = "./modules/aliyun_ipv6"
  vpc_id = module.aliyun_vpc_hz.vpc_id
  instance_ids = {
    hz0 = alicloud_instance.hz0.id
  }
}

module "aliyun_dns" {
  source = "./modules/aliyun_dns"
  domain = "szp15.com"
  records = {
    hz0_A    = { host_record = "hz0", type = "A", value = module.aliyun_ipv4_hz.ip_addresses.hz0 }
    hz0_AAAA = { host_record = "hz0", type = "AAAA", value = module.aliyun_ipv6_hz.ipv6_addresses.hz0 }

    zjk0_A    = { host_record = "zjk0", type = "A", value = "47.92.30.246" }
    zjk0_AAAA = { host_record = "zjk0", type = "AAAA", value = "2408:4001:208:4900:a244:6016:2560:98b2" }

    firefly  = { host_record = "firefly", type = "CNAME", value = "zjk0.szp15.com" }
    god      = { host_record = "god", type = "CNAME", value = "zjk0.szp15.com" }
    commento = { host_record = "commento", type = "CNAME", value = "zjk0.szp15.com" }
    file     = { host_record = "file", type = "CNAME", value = "zjk0.szp15.com" }
    "@"      = { host_record = "@", type = "CNAME", value = "zjk0.szp15.com" }
  }
}

locals {
  aliyun_nodes = {
    aliyun-hz0 = {
      fqdn = "hz0.szp15.com"
      ipv4 = module.aliyun_ipv4_hz.ip_addresses.hz0
      ipv6 = module.aliyun_ipv6_hz.ipv6_addresses.hz0
      tags = []
    }
  }
}
