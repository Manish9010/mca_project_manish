terraform {
  required_version = ">= 1.5.1"
  backend "s3" {}
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.41.0"
    }
  }
}

provider "aws" {
  region = "ap-south-2"
}