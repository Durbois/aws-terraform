data "aws_vpc" "vpc_eks" {
    id = var.vpc_id
}

data "aws_availability_zones" "available" {}

locals {
  name            = "ex-${replace(basename(path.cwd), "_", "-")}"
  cluster_version = "1.27"
  region          = var.region

  vpc_cidr = data.aws_vpc.vpc_eks.cidr_block
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "aws-terraform"
    GithubOrg  = "terraform-aws-modules"
  }
}