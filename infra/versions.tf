terraform {
  required_providers {
    alicloud = {
      source = "registry.terraform.io/aliyun/alicloud"
    }
    sops = {
      source = "registry.terraform.io/carlpett/sops"
    }
  }
}