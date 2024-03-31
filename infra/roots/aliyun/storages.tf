resource "alicloud_oss_bucket" "seafile_commits" {
  bucket          = "szpio-seafile-commits"
  acl             = "private"
  storage_class   = "Standard"
  redundancy_type = "LRS"
}

resource "alicloud_oss_bucket" "seafile_fs" {
  bucket          = "szpio-seafile-fs"
  acl             = "private"
  storage_class   = "Standard"
  redundancy_type = "LRS"
}

resource "alicloud_oss_bucket" "seafile_block" {
  bucket          = "szpio-seafile-block"
  acl             = "private"
  storage_class   = "Standard"
  redundancy_type = "LRS"
}
