terraform {
  backend "s3" {
    bucket  = "terraform-tfstate-216977899830"
    key     = "infra/rds.tfstate"
    encrypt = "true"
    region  = "us-east-1"
  }
}