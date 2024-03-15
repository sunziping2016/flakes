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
