resource "alicloud_oss_bucket" "owncloud" {
  bucket          = "owncloud-hz0"
  acl             = "private"
  storage_class   = "Standard"
  redundancy_type = "LRS"
}
