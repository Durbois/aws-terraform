# aws-terraform
Build Aws Infrastructure with terraform

Subnet Calculator: https://nuvibit.com/vpc-subnet-calculator/

1. Build the first infra
Needs:
- VPC
- Internet Gateway
- Route table for Internet Gateway
- EC2
- Security Group from Internet to EC2 ssh
- Create an AWS Keypair to connect to the EC2 Instance

ToDo: Maps Subnet Ip with Variable ips
Create Route Table Association https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association