module "szp15" {
  source = "../../modules/aliyun_dns"
  domain = "szp15.com"
  records = {
    hz0_A         = { host_record = "hz0", type = "A", value = module.ipv4_hz.ip_addresses.hz0 }
    hz0_ipv4_A    = { host_record = "ipv4.hz0", type = "A", value = module.ipv4_hz.ip_addresses.hz0 }
    hz0_AAAA      = { host_record = "hz0", type = "AAAA", value = module.ipv6_hz.ipv6_addresses.hz0 }
    hz0_ipv6_AAAA = { host_record = "ipv6.hz0", type = "AAAA", value = module.ipv6_hz.ipv6_addresses.hz0 }
    hz1_A         = { host_record = "hz1", type = "A", value = alicloud_instance.hz1.public_ip }
    hz1_ipv4_A    = { host_record = "ipv4.hz1", type = "A", value = alicloud_instance.hz1.public_ip }
    hz1_AAAA      = { host_record = "hz1", type = "AAAA", value = module.ipv6_hz.ipv6_addresses.hz1 }
    hz1_ipv6_AAAA = { host_record = "ipv6.hz1", type = "AAAA", value = module.ipv6_hz.ipv6_addresses.hz1 }

    zjk0_A = { host_record = "zjk0", type = "A", value = "47.92.30.246" }

    firefly  = { host_record = "firefly", type = "CNAME", value = "zjk0.szp15.com" }
    god      = { host_record = "god", type = "CNAME", value = "zjk0.szp15.com" }
    commento = { host_record = "commento", type = "CNAME", value = "zjk0.szp15.com" }
    file     = { host_record = "file", type = "CNAME", value = "zjk0.szp15.com" }
    "@"      = { host_record = "@", type = "CNAME", value = "zjk0.szp15.com" }

    mc  = { host_record = "mc", type = "CNAME", value = "hz0.szp15.com" }
    map = { host_record = "map", type = "CNAME", value = "hz0.szp15.com" }
  }
}
