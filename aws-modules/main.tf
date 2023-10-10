module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = "vpc_lb"
    cidr = var.vpc

    azs = [for k, v in var.subnets: v.az if strcontains(k, var.public_substr) ]
    private_subnets = [for k, v in var.subnets: v.ip if strcontains(k, var.private_substr)]
    public_subnets = [for k, v in var.subnets: v.ip if strcontains(k, var.public_substr)]    

    tags = {
        Terraform = "true"
        Environment = "dev"
    }
}


output "azs_list" {
    value = module.vpc.azs
}