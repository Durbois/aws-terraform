# aws-terraform
Build Aws Infrastructure with terraform

Subnet Calculator: https://nuvibit.com/vpc-subnet-calculator/
In case you encounter a plugin.(*GRPCProvider) issue: export GODEBUG=asyncpreemptoff=1

1. Build the first infra
Needs:
- VPC
- Internet Gateway
- Route table for Internet Gateway
- EC2
- Security Group from Internet to EC2 ssh
- Create an AWS Keypair to connect to the EC2 Instance

ToDo:
- create asg with min 1, max 2 --> https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#instance_generations
- Make sure you can connect from the created instances
- create az where your instances should launch --> update the draw.io diagramm
- integrated an elb on top of the ASG
- Work with environment workspaces [tst, prd]