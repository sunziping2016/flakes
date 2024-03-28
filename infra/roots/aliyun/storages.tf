resource "alicloud_oss_bucket" "seafile" {
  bucket          = "seafile-hz0"
  acl             = "private"
  storage_class   = "Standard"
  redundancy_type = "LRS"
}
