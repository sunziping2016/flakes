data "sops_file" "secrets" {
  source_file = "secrets.yaml"
}

locals {
  secrets = yamldecode(data.sops_file.secrets.raw)
}

provider "alicloud" {
  access_key = local.secrets.aliyun.access_key
  secret_key = local.secrets.aliyun.secret_key
  region     = "cn-hangzhou"
}

provider "alicloud" {
  alias      = "zjk"
  access_key = local.secrets.aliyun.access_key
  secret_key = local.secrets.aliyun.secret_key
  region     = "cn-zhangjiakou"
}
