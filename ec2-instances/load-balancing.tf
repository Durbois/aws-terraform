resource "aws_lb" "load_balancing" {
    name = "app-lb"
    # internal  = false

    security_groups = [aws_security_group.sg_lb.id]

    subnets = [for key, val in aws_subnet.subnets: val.id if strcontains(val.tags.Name, var.contains)]
}

resource "aws_lb_listener" "listener_80" {
  load_balancer_arn = aws_lb.load_balancing.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }
}

# resource "aws_lb_listener" "listener_81" {
#   load_balancer_arn = aws_lb.load_balancing.arn
#   port = 81
#   protocol = "HTTP"

#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.target.arn
#   }
# }

resource "aws_lb_listener" "listener_83" {
  load_balancer_arn = aws_lb.load_balancing.arn
  port = 83
  protocol = "HTTP"

  default_action {
    type = "fixed-response"
    
    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }  
  }
}

resource "aws_lb_listener_rule" "http_based_fixed_response" {
  listener_arn = aws_lb_listener.listener_83.arn
  priority     = 3

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }

  condition {
    path_pattern {
      values = ["/fixed-response/*"]
    }
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.listener_80.arn
  priority     = 4

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }

  condition {
    path_pattern {
      values = ["/forward/*"]
    }
  }
}

# resource "aws_lb_listener_rule" "rule" {
#   listener_arn = aws_lb_listener.listener.arn

#   action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.target.arn
#   } 

#   condition {
#     path_pattern {
#       values = ["/"] #ToDo: remove and test
#     }
#   }
# }


resource "aws_lb_target_group" "target" {
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  target_type = "instance"
  ip_address_type = "ipv4"
  
  health_check {
    enabled             = true
    port                = 80
    interval            = 30
    protocol            = "HTTP"
    path                = "/healthz"
    matcher             = "200-399"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

}

resource "aws_security_group" "sg_lb" {
  name = "load_balancing_security_group"
  description = "This is to allow ingress from internet to the ELB"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP web traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]    
  }  

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}