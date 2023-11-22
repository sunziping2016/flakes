resource "alicloud_alidns_domain" "szp-cn" {
  domain_name = "szp15.com"
}

resource "alicloud_alidns_record" "A-hz0-szp-cn" {
  domain_name = alicloud_alidns_domain.szp-cn.domain_name
  rr          = "hz0"
  type        = "A"
  value       = alicloud_instance.hz0.public_ip
}

resource "alicloud_alidns_record" "AAAA-hz0-szp-cn" {
  domain_name = alicloud_alidns_domain.szp-cn.domain_name
  rr          = "hz0"
  type        = "AAAA"
  value       = tolist(alicloud_instance.hz0.ipv6_addresses)[0]
}
