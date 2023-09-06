resource "aws_vpc" "main" {
  cidr_block = var.ips["vpc"]

  tags       = var.tags
}


resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id

  tags   = var.tags
}


resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags         = var.tags
}

resource "aws_subnet" "public_subnet" {
  cidr_block = var.ips["public_subnet_a"]
  vpc_id     = aws_vpc.main.id
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}

data "aws_key_pair" "ec2_key" {
  key_name = "ec2-key"
  include_public_key = true

  filter {
    name = "key-pair-id"
    values = ["key-0d05f3162c1bf0576"]
  }
}

resource "aws_instance" "public_ec2" {
  ami                    = var.amis["linux_23"]
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = data.aws_key_pair.ec2_key.id 
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  
  
  tags            = var.tags
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = var.tags
}