# Setup 

# AWS Provider from Hashicorp
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.29"
    }
  }
}


# Things we need for aws

provider "aws" {
  region = var.aws_region
}

