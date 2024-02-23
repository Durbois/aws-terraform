# Using multiple workspaces:
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "tah-org"

    workspaces {
      prefix = "ecr-terraform"
    }
  }
}