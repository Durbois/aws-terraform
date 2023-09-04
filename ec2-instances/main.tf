resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/28"

  tags = {
    Name = "main",
    environment = "dev"
  }
}