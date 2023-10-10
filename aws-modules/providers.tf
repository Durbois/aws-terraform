terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
#  region = "eu-central-1"
  shared_config_files      = ["/Users/tah/.aws/config"]
  shared_credentials_files = ["/Users/tah/.aws/credentials"]
  profile                  = "default"  
}

