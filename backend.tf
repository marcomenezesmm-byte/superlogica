terraform {
  backend "s3" {
    bucket  = "terraform-tfstate-216977899830"
    key     = "infra/rds.tfstate"
    encrypt = "true"
    region  = "us-east-1"
  }
}

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}