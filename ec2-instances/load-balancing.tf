resource "aws_lb" "load_balancing" {
    name = "app-lb"
    enable_deletion_protection = false

    security_groups = [aws_security_group.sg_lb.id]

    subnets = [for key, val in aws_subnet.subnets: val.id if strcontains(val.tags.Name, var.contains)]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.load_balancing.arn
  port = 80

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.target.arn
        weight = 99
      }
    } 
  }
}

resource "aws_lb_listener_rule" "rule" {
  listener_arn = aws_lb_listener.listener.arn
  priority = 99

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  } 

  condition {
    path_pattern {
      values = ["/terraform/*"]
    }
  }
}

resource "aws_lb_target_group" "target" {
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "sg_lb" {
  name = "load_balancing_security_group"
  description = "This is to allow ingress from internet to the ELB"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Access from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]    
  }  
}