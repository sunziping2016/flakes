terraform {
  backend "s3" {
    bucket         = "szpio-apse1-terraform-backend"
    key            = "flakes/aliyun.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "TerraformStateLock"
  }
}
