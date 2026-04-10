terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # We will use variables for backend configuration, or define it here.
  # Make sure the S3 bucket & DynamoDB table exist before running terraform init with this uncommented.
  backend "s3" {
    bucket         = "taskapp-capstone-tf-state-unique123" # Must be unique! Change this when deploying
    key            = "terraform/state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "taskapp-tf-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
