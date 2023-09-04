resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/24"

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
    gateway_id = aws_internet_gateway.example.id
  }

  tags = var.tags
}

resource "aws_subnet" "public-subnet" {
  cidr_block = "172.16.0.16/28"
  vpc_id     = aws_vpc.main.id
}

