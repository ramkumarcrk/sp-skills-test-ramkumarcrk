terraform {
  backend "s3" {
    bucket = "terraform-remote-state-spc"
    key    = "consul-cluster/terraform.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region = "us-east-1"
}



#Resource to Create Key Pair default
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = var.public_key
}




data "aws_vpcs" "prod_vpcs" {
  filter {
    name   = "tag:Environment"
    values = ["snowplow-prd"]
  }
}


module "consul_cluster" {
  source = "./modules/consul_cluster"

  allowed_inbound_cidrs  = var.allowed_inbound_cidrs
  instance_type          = var.instance_type
  consul_version         = var.consul_version
  consul_cluster_version = var.consul_cluster_version
  acl_bootstrap_bool     = var.acl_bootstrap_bool
  key_name               = var.key_name
  name_prefix            = var.name_prefix
  #  vpc_id                 = var.vpc_id
  vpc_id         = data.aws_vpcs.prod_vpcs.id
  public_ip      = var.public_ip
  consul_servers = var.consul_servers
  consul_clients = var.consul_clients
  consul_config  = var.consul_config
  enable_connect = var.enable_connect
  owner          = var.owner
}
