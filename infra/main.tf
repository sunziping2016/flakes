data "alicloud_instance_types" "instance_type" {
  instance_type_family = "ecs.t6"
  cpu_core_count       = "2"
  memory_size          = "4"
}

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

data "alicloud_zones" "zones_ds" {
  available_instance_type     = data.alicloud_instance_types.instance_type.ids[0]
  available_disk_category     = "cloud_efficiency"
  available_resource_creation = "VSwitch"
}

resource "alicloud_vswitch" "vswitch" {
  vpc_id               = alicloud_vpc.vpc.id
  zone_id              = data.alicloud_zones.zones_ds.ids[0]
  enable_ipv6          = true
  cidr_block           = cidrsubnet(alicloud_vpc.vpc.cidr_block, 12, 0)
  ipv6_cidr_block_mask = 64
}

data "alicloud_images" "default" {
  name_regex = "^ubuntu_[0-9]+_[0-9]+_uefi_x64*"
  owners     = "system"
}

resource "alicloud_instance" "hz0" {
  availability_zone = data.alicloud_zones.zones_ds.ids[0]
  security_groups   = [alicloud_security_group.group.id]

  image_id                   = data.alicloud_images.default.ids[0]
  instance_type              = data.alicloud_instance_types.instance_type.ids[0]
  system_disk_category       = "cloud_efficiency"
  system_disk_size           = 80
  instance_charge_type       = "PostPaid"
  internet_charge_type       = "PayByTraffic"
  internet_max_bandwidth_out = 100
  vswitch_id                 = alicloud_vswitch.vswitch.id
  ipv6_address_count         = 1
  key_name                   = "cardno:19_795_283"
}
