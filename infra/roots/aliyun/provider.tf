terraform {
  required_providers {
    alicloud = {
      source = "registry.terraform.io/aliyun/alicloud"
    }
    local = {
      source = "registry.terraform.io/hashicorp/local"
    }
  }
}

provider "alicloud" {
  region = "cn-hangzhou"
}
