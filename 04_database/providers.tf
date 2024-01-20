
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0" # AWS provider version, not terraform version
    }
  }

  backend "s3" { 
     bucket = "terraform-env--dev"
     key    = "roboshop_terraform_dev_databases"
     region = "us-east-1"
     dynamodb_table = "Terraform-env-dev"
  }
}

provider "aws" {
  region = "us-east-1"
}