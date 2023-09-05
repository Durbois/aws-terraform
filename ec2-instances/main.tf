resource "aws_vpc" "main" {
  cidr_block = var.ips["vpc"]

  tags = var.tags
}


resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}


resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = var.tags
}

resource "aws_subnet" "public-subnet" {
  cidr_block = var.ips["public-subnet-a"]
  vpc_id     = aws_vpc.main.id
}

