module "aliyun_dns" {
  source = "./modules/aliyun_dns"
  domain = "szp15.com"
  records = merge(
    {
      hz0_A  = { host_record = "hz0", type = "A", value = alicloud_instance.hz0.public_ip }
      zjk0_A = { host_record = "zjk0", type = "A", value = alicloud_instance.zjk0.public_ip }
    },
    {
      for i, v in tolist(alicloud_instance.hz0.ipv6_addresses) :
      "hz0_AAAA_${i}" => { host_record = "hz0", type = "AAAA", value = v }
    },
    {
      for i, v in tolist(alicloud_instance.zjk0.ipv6_addresses) :
      "zjk0_AAAA_${i}" => { host_record = "zjk0", type = "AAAA", value = v }
    },
    {
      firefly  = { host_record = "firefly", type = "CNAME", value = "zjk0.szp15.com" }
      god      = { host_record = "god", type = "CNAME", value = "zjk0.szp15.com" }
      commento = { host_record = "commento", type = "CNAME", value = "zjk0.szp15.com" }
      file     = { host_record = "file", type = "CNAME", value = "zjk0.szp15.com" }
      "@"      = { host_record = "@", type = "CNAME", value = "zjk0.szp15.com" }
    }
  )
}
