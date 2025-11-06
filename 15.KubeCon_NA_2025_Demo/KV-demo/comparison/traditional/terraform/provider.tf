terraform {
  required_version = "1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 backend for state management
  backend "s3" {
    bucket = "terraform-state-kubecon-demo"
    key    = "product-catalog/terraform.tfstate"
    region = "us-west-2"
    # Enable encryption
    encrypt = true
    # DynamoDB table for state locking
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}
