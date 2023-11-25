terraform {
  required_providers {
    alicloud = {
      source = "registry.terraform.io/aliyun/alicloud"
    }
  }
}

resource "alicloud_alidns_domain" "this" {
  domain_name = var.domain
}

resource "alicloud_alidns_record" "this" {
  for_each    = var.records
  domain_name = var.domain
  rr          = each.value.host_record
  type        = each.value.type
  value       = each.value.value
  ttl         = each.value.ttl
  priority    = each.value.priority
}
