module "alb" {
    source  = "terraform-aws-modules/alb/aws"

    name = "my-alb"

    load_balancer_type = "application"

    vpc_id = module.vpc.vpc_id
    subnets = module.vpc.public_subnets
    # Attach security groups
    security_groups = [module.vpc.default_security_group_id]

    # Attach rules to the created security group
    security_group_rules = {
        ingress_all_http = {
        type        = "ingress"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        description = "HTTP web traffic"
        cidr_blocks = ["0.0.0.0/0"]
        }
        ingress_all_icmp = {
        type        = "ingress"
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        description = "ICMP"
        cidr_blocks = ["0.0.0.0/0"]
        }
        egress_all = {
        type        = "egress"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        }
    }    

    http_tcp_listeners = [
        # Forward action is default, either when defined or undefined
        {
        port               = 80
        protocol           = "HTTP"
        target_group_index = 0
        # action_type        = "forward"
        },
        {
        port        = 81
        protocol    = "HTTP"
        action_type = "forward"
        forward = {
                target_groups = [
                {
                    target_group_index = 0
                    weight             = 100
                }
                ]
            }
        },
        {
        port        = 83
        protocol    = "HTTP"
        action_type = "fixed-response"
        fixed_response = {
            content_type = "text/plain"
            message_body = "Fixed message"
            status_code  = "200"
            }
        }
    ]

    http_tcp_listener_rules = [
        {
        http_tcp_listener_index = 0
        priority                = 3
        actions = [{
            type         = "fixed-response"
            content_type = "text/plain"
            status_code  = 200
            message_body = "This is a fixed response"
        }]

        conditions = [{
            http_headers = [{
                http_header_name = "x-Gimme-Fixed-Response"
                values           = ["yes", "please", "right now"]
            }]
        }]
        },
        {
        http_tcp_listener_index = 0
        priority                = 4

        actions = [{
            type = "weighted-forward"
            target_groups = [
            {
                target_group_index = 0
                weight             = 1
            }
            ]
            stickiness = {
                enabled  = true
                duration = 3600
            }
        }]

        conditions = [{
            query_strings = [{
                key   = "weighted"
                value = "true"
            }]
        }]
        },
        {
        http_tcp_listener_index = 0
        priority                = 5000
        actions = [{
            type        = "redirect"
            status_code = "HTTP_302"
            host        = "www.youtube.com"
            path        = "/watch"
            query       = "v=dQw4w9WgXcQ"
            protocol    = "HTTPS"
        }]

        conditions = [{
            query_strings = [{
            key   = "video"
            value = "random"
            }]
        }]
        }
    ]

    target_groups = [
        {
        name_prefix                       = "h1"
        backend_protocol                  = "HTTP"
        backend_port                      = 80
        target_type                       = "instance"
        deregistration_delay              = 10
        load_balancing_cross_zone_enabled = false
        health_check = {
            enabled             = true
            interval            = 30
            path                = "/healthz"
            port                = "traffic-port"
            healthy_threshold   = 3
            unhealthy_threshold = 3
            timeout             = 6
            protocol            = "HTTP"
            matcher             = "200-399"
        }
        protocol_version = "HTTP1"
        targets = {
            my_ec2 = {
            target_id = aws_instance.this.id
            port      = 80
            },
            my_ec2_again = {
            target_id = aws_instance.this.id
            port      = 8080
            }
        }
        tags = {
            InstanceTargetGroupTag = "baz"
        }
        }
    ]
}

##################
# Extra resources
##################

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.nano"
  subnet_id     = element(module.vpc.private_subnets, 0)
}