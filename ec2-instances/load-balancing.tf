resource "aws_lb" "load_balancing" {
    name = "app-lb"
    enable_deletion_protection = false

    security_groups = [aws_security_group.sg_lb.id]

    subnets = [for key, val in aws_subnet.subnets: val.id if strcontains(val.tags.Name, var.contains)]
}

resource "aws_security_group" "sg_lb" {
  name = "load_balancing_security_group"
  description = "This is to allow ingress from internet to the ELB"

  ingress {
    description = "Access from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]    
  }  
}