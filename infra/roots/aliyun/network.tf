module "vpc_hz" {
  source     = "../../modules/aliyun_vpc"
  cidr_block = "172.16.0.0/12"
  vswitches = {
    h = { zone_id = "cn-hangzhou-h", netnum = 0 }
  }
}

module "ipv4_hz" {
  source             = "../../modules/aliyun_ipv4"
  vpc_id             = module.vpc_hz.vpc_id
  vpc_route_table_id = module.vpc_hz.route_table_id
  instance_ids = {
    hz0 = alicloud_instance.hz0.id
  }
}

module "ipv6_hz" {
  source = "../../modules/aliyun_ipv6"
  vpc_id = module.vpc_hz.vpc_id
  instance_ids = {
    hz0 = alicloud_instance.hz0.id
    hz1 = alicloud_instance.hz1.id
  }
}
