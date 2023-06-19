terraform {
  backend "s3" {
    bucket = "terraform-remote-state-spc"
    key    = "vpcendpoints/terraform.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "vpc_ep" {
  filter {
    name   = "tag:Environment"
    values = ["snowplow-prd"]
  }
}

data "aws_subnets" "vpc_ep_sub" {
  filter {
    name   = "tag:Name"
    values = ["snowplow-prd-vpc-private-us-east-*"]
  }

}


data "aws_subnet" "alb_vpcep_sub" {
  for_each = toset(data.aws_subnets.vpc_ep_sub.ids)
  id       = each.value
}


resource "aws_vpc_endpoint" "ec2_vpcep" {
  service_name      = "com.amazonaws.us-east-1.ssm"
  subnet_ids        = [for s in data.aws_subnet.alb_vpcep_sub : s.id]
  security_group_ids= [aws_security_group.sp_sg_vpcep.id]
  vpc_endpoint_type = "Interface"
  vpc_id            = data.aws_vpc.vpc_ep.id
  private_dns_enabled = true
}


resource "aws_vpc_endpoint" "ec2_vpcep_ss" {
  service_name      = "com.amazonaws.us-east-1.ssmmessages"
  subnet_ids        = [for s in data.aws_subnet.alb_vpcep_sub : s.id]
  security_group_ids= [aws_security_group.sp_sg_vpcep.id]
  vpc_endpoint_type = "Interface"
  vpc_id            = data.aws_vpc.vpc_ep.id
  private_dns_enabled = true
}

resource "aws_security_group" "sp_sg_vpcep" {
  name        = "vpcep-security-group"
  description = "vpcep-security-group"
  vpc_id      = data.aws_vpc.vpc_ep.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
