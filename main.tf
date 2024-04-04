terraform {
  required_version = ">= 1.5.1"
}

terraform {
  backend "s3" {
    bucket         = "mca-project-bucket"
    key            = "mca-project-statefile.tfstate"
    region         = "ap-south-2"
   // access_key     = "your_access_key" # Optional if using IAM roles
   // secret_key     = "your_secret_key" # Optional if using IAM roles
   // dynamodb_table = "terraform_locks" # Optional: If you want to enable state locking with DynamoDB
  }
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

#terraform main entry