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
- create asg with min 1, max 2 (done)
- Make sure you can connect from the created instances (done)
- create az where your instances should launch (done)
- add script to show your ip instance (done)
- integrated an elb on top of the ASG (deploy Infra, warum ist der TargetGroup unhealhty? siehe https://antonputra.com/amazon/create-alb-terraform/#create-aws-alb-with-auto-scaling-group) (Solution not found)
- Bind Load Balancing in front of Cognito 
- Work with environment workspaces [tst, prd]