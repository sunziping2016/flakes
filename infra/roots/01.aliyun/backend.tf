terraform {
  backend "s3" {
    bucket         = "szpio-apse1-terraform-backend"
    key            = "flakes/01.aliyun.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "TerraformStateLock"
  }
}
