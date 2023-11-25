resource "alicloud_security_group" "group" {
  description = "OpenTofu security group"
  vpc_id      = alicloud_vpc.vpc.id
}


resource "alicloud_security_group_rule" "ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "22/22"
  nic_type          = "intranet"
  security_group_id = alicloud_security_group.group.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_vpc" "vpc" {
  cidr_block  = "172.16.0.0/12"
  enable_ipv6 = true
}

resource "alicloud_vswitch" "vswitch" {
  vpc_id               = alicloud_vpc.vpc.id
  zone_id              = "cn-hangzhou-h"
  enable_ipv6          = true
  cidr_block           = cidrsubnet(alicloud_vpc.vpc.cidr_block, 12, 0)
  ipv6_cidr_block_mask = 64
}

resource "alicloud_instance" "hz0" {
  force_delete      = true
  availability_zone = "cn-hangzhou-h"
  security_groups   = [alicloud_security_group.group.id]

  image_id                   = "ubuntu_22_04_uefi_x64_20G_alibase_20230515.vhd"
  instance_type              = "ecs.t6-c1m2.large"
  system_disk_size           = 80
  instance_charge_type       = "PostPaid"
  internet_charge_type       = "PayByTraffic"
  internet_max_bandwidth_out = 100
  vswitch_id                 = alicloud_vswitch.vswitch.id
  ipv6_address_count         = 1
  key_name                   = "cardno:19_795_283"
}

resource "alicloud_instance" "zjk0" {
  provider          = alicloud.zjk
  force_delete      = true
  availability_zone = "cn-zhangjiakou-a"
  security_groups   = ["sg-8vbb8qrmp4ouooy1a8cs"]

  image_id                            = "ubuntu_18_04_64_20G_alibase_20191112.vhd"
  instance_type                       = "ecs.t6-c1m2.large"
  instance_charge_type                = "PrePaid"
  internet_max_bandwidth_out          = 100
  system_disk_auto_snapshot_policy_id = "sp-8vb9kfhqeeyv2a3t5uxf"
  vswitch_id                          = "vsw-8vb1stovi3qoofvqqeeyv"
  ipv6_address_count                  = 1
}
