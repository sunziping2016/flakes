terraform {
  backend "s3" {
    bucket         = "szpio-apse1-terraform-backend"
    key            = "flakes/keycloak.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "TerraformStateLock"
  }
}
