provider "aws" {
  region = local.region
}

locals {
  region = "eu-central-1"
  name   = "python-app"

  tags = {
    Name       = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecr"
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

################################################################################
# ECR Repository
################################################################################

module "ecr_disabled" {
  source = "terraform-aws-modules/ecr/aws"

  create = false
}

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = local.name

  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  repository_image_tag_mutability = MUTABLE
  create_lifecycle_policy           = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_force_delete = true

  tags = local.tags
}