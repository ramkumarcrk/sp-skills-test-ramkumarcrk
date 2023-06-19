# Provider configuration
provider "aws" {
  region = "us-east-1" # Update with your desired region
}

terraform {
  backend "s3" {
    bucket = "terraform-remote-state-spc"
    key    = "applicationlb/terraform.tfstate"
    region = "us-east-1"
  }
}


# Create an ALB
resource "aws_lb" "application" {
  name               = "lb-snowplow-application"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.consul_sg_alb.id]
  subnets            = [for s in data.aws_subnet.alb_sub : s.id]

  tags = {
    Terraform   = "true"
    Environment = "snowplow-prd-alb01"
  }

}

# Create a target group
resource "aws_lb_target_group" "tg-application" {
  name     = "tg-snowplow-app-lb"
  port     = 8500
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.alb_vpc.id

health_check {
        enabled             = true
        interval            = 30
        path                = "/v1/catalog/service/consul"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTPS"
        matcher             = "200-399"
  }
  
  stickiness  {
      cookie_duration = 86400
      enabled         = true
      type            = "lb_cookie"
  }

}

# Attach the ALB to the target group
resource "aws_lb_listener" "application" {
  load_balancer_arn = aws_lb.application.arn
  port              = 8500
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg-application.arn
    type             = "forward"
  }
}

# Retrieve the existing Auto Scaling Group
data "aws_autoscaling_groups" "existing_asg" {
filter {
    name = "tag:Name"
    values = ["snowplow-prd-consul-server"]

}
}

data "aws_autoscaling_group" "alb_asg" {
  for_each = toset(data.aws_autoscaling_groups.existing_asg.names)
  name    = each.value
}


locals {
  alb_asg_names = [for key, value in data.aws_autoscaling_group.alb_asg : value.name]
}


# Attach the target group to the existing Auto Scaling Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = local.alb_asg_names[0]
  lb_target_group_arn    = aws_lb_target_group.tg-application.arn
}


#Retrieve the subnet id

data "aws_vpc" "alb_vpc" {
  filter {
    name   = "tag:Environment"
    values = ["snowplow-prd"]
  }
}

data "aws_subnets" "alb" {
  filter {
    name   = "tag:Name"
    values = ["snowplow-prd-vpc-public-us-east-*"]
  }

}


data "aws_subnet" "alb_sub" {
  for_each = toset(data.aws_subnets.alb.ids)
  id       = each.value
}


resource "aws_security_group" "consul_sg_alb" {
  name        = "bastion-security-group"
  description = "bastion-security-group"
  vpc_id      = data.aws_vpc.alb_vpc.id

  ingress {
    from_port   = 8000
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["86.29.8.201/32","34.74.90.64/28","34.74.226.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


output "external-alb-to-access" {

value = "${aws_lb.application.dns_name}:8500/v1/kv"
}
