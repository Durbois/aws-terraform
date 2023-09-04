resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/24"

  tags = var.tags
}


resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}
