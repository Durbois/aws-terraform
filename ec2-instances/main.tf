resource "aws_vpc" "main" {
  cidr_block = var.vpc

  tags = var.tags
}


resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}


resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = var.tags
}

resource "aws_subnet" "subnets" {
  for_each = var.subnets
  vpc_id = aws_vpc.main.id
  cidr_block = each.value.ip
  availability_zone = each.value.az

  tags = {
    Name = each.key
  }
}

# resource "aws_subnet" "public_subnet" {
#   cidr_block = var.subnets["public_subnet_a"]
#   vpc_id     = aws_vpc.main.id
# }

resource "aws_route_table_association" "public_association" {
  for_each =  {for key, val in aws_subnet.subnets: key => val if strcontains(val.tags.Name, var.contains)}
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_table.id
}

data "aws_key_pair" "ec2_key" {
  key_name           = "ec2-key"
  include_public_key = true

  filter {
    name   = "key-name"
    values = ["ec2-key"]
  }
}

# resource "aws_instance" "public_ec2" {
#   ami                    = var.amis["linux_23"]
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.public_subnet.id
#   key_name               = data.aws_key_pair.ec2_key.key_name
#   vpc_security_group_ids = [aws_security_group.allow_traffic.id]

#   associate_public_ip_address = "true"


#   tags = var.tags
# }

resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    # security_groups  = [aws_security_group.sg_lb.id]
    cidr_blocks      = ["0.0.0.0/0"]
  } 

   ingress {
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    # security_groups  = [aws_security_group.sg_lb.id]
    cidr_blocks      = ["0.0.0.0/0"]
  } 

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = var.tags
}

data "aws_ami" "amz_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "template" {
  image_id = data.aws_ami.amz_ami.id
  instance_type = "t2.micro"
  key_name = data.aws_key_pair.ec2_key.key_name
  user_data = base64encode(file("userdata.tpl"))
  # vpc_security_group_ids = [ aws_security_group.allow_traffic.id ]


  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.allow_traffic.id]
  }

  tags = var.tags

}

resource "aws_autoscaling_group" "auto_scaling" {
  name = "auto_scaling"
  desired_capacity = 2
  max_size = 3
  min_size = 1

  health_check_type = "EC2"
  
  vpc_zone_identifier = [
    for key, val in aws_subnet.subnets: val.id if strcontains(val.tags.Name, var.contains)
  ]

  launch_template {
    id = aws_launch_template.template.id
    version = aws_launch_template.template.latest_version
  }

  target_group_arns = [aws_lb_target_group.target.arn]
}