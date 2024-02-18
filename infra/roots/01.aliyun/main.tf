terraform {
  required_providers {
    alicloud = {
      source = "registry.terraform.io/aliyun/alicloud"
    }
  }
}

provider "alicloud" {
  region = "cn-hangzhou"
}

module "aliyun_vpc_hz" {
  source     = "../../modules/aliyun_vpc"
  cidr_block = "172.16.0.0/12"
  vswitches = {
    hz_h = { zone_id = "cn-hangzhou-h", netnum = 0 }
  }
}

module "aliyun_security_group_hz" {
  source = "../../modules/aliyun_security_group"
  vpc_id = module.aliyun_vpc_hz.vpc_id
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
  security_groups      = [module.aliyun_security_group_hz.id]
  image_id             = "ubuntu_22_04_uefi_x64_20G_alibase_20230515.vhd"
  instance_type        = "ecs.e-c1m4.large"
  instance_charge_type = "PrePaid"
  vswitch_id           = module.aliyun_vpc_hz.vswhitch_ids.hz_h
  key_name             = "cardno:19_795_283"
}

resource "alicloud_instance" "hz1" {
  force_delete         = true
  availability_zone    = "cn-hangzhou-h"
  security_groups      = [module.aliyun_security_group_hz.id]
  image_id             = "ubuntu_22_04_uefi_x64_20G_alibase_20230515.vhd"
  instance_type        = "ecs.e-c1m1.large"
  instance_charge_type = "PrePaid"
  vswitch_id           = module.aliyun_vpc_hz.vswhitch_ids.hz_h
  key_name             = "cardno:19_795_283"
  ipv6_address_count   = 1
  renewal_status       = "AutoRenewal"
  auto_renew_period    = 12
}

module "aliyun_ipv4_hz" {
  source             = "../../modules/aliyun_ipv4"
  vpc_id             = module.aliyun_vpc_hz.vpc_id
  vpc_route_table_id = module.aliyun_vpc_hz.route_table_id
  instance_ids = {
    hz0 = alicloud_instance.hz0.id
  }
}

module "aliyun_ipv6_hz" {
  source = "../../modules/aliyun_ipv6"
  vpc_id = module.aliyun_vpc_hz.vpc_id
  instance_ids = {
    hz0 = alicloud_instance.hz0.id
  }
}

module "aliyun_dns" {
  source = "../../modules/aliyun_dns"
  domain = "szp15.com"
  records = {
    hz0_A    = { host_record = "hz0", type = "A", value = module.aliyun_ipv4_hz.ip_addresses.hz0 }
    hz0_AAAA = { host_record = "hz0", type = "AAAA", value = module.aliyun_ipv6_hz.ipv6_addresses.hz0 }
    hz1_A    = { host_record = "hz1", type = "A", value = alicloud_instance.hz1.public_ip }
    hz1_AAAA = { host_record = "hz1", type = "AAAA", value = tolist(alicloud_instance.hz1.ipv6_addresses)[0] }

    zjk0_A = { host_record = "zjk0", type = "A", value = "47.92.30.246" }

    firefly  = { host_record = "firefly", type = "CNAME", value = "hz0.szp15.com" }
    god      = { host_record = "god", type = "CNAME", value = "zjk0.szp15.com" }
    commento = { host_record = "commento", type = "CNAME", value = "zjk0.szp15.com" }
    file     = { host_record = "file", type = "CNAME", value = "zjk0.szp15.com" }
    idm      = { host_record = "idm", type = "CNAME", value = "hz0.szp15.com" }
    hydra    = { host_record = "hydra", type = "CNAME", value = "hz0.szp15.com" }
    auth     = { host_record = "auth", type = "CNAME", value = "hz0.szp15.com" }
    ocis     = { host_record = "ocis", type = "CNAME", value = "hz0.szp15.com" }
    "@"      = { host_record = "@", type = "CNAME", value = "zjk0.szp15.com" }
  }
}

resource "alicloud_oss_bucket" "owncloud" {
  bucket          = "owncloud-hz0"
  acl             = "private"
  storage_class   = "Standard"
  redundancy_type = "LRS"
}
