variable "acl_bootstrap_bool" {
  type        = bool
  default     = true
  description = "Initial ACL Bootstrap configurations"
}

variable "allowed_inbound_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks to permit inbound Consul access from"
}

variable "consul_clients" {
  default     = "3"
  description = "number of Consul instances"
}

variable "consul_config" {
  description = "HCL Object with additional configuration overrides supplied to the consul servers.  This is converted to JSON before rendering via the template."
  default     = {}
}

variable "consul_cluster_version" {
  default     = "0.0.1"
  description = "Custom Version Tag for Upgrade Migrations"
}

variable "consul_servers" {
  default     = "5"
  description = "number of Consul instances"
}

variable "consul_version" {
  description = "Consul version"
  default     = "1.15.3"
}

variable "enable_connect" {
  type        = bool
  description = "Whether Consul Connect should be enabled on the cluster"
  default     = false
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Instance type for Consul instances"
}

variable "key_name" {
  default     = "default"
  description = "SSH key name for Consul instances"
}

variable "name_prefix" {
  description = "prefix used in resource names"
  default     = "snowplow-prd"
}

variable "owner" {
  description = "value of owner tag on EC2 instances"
  default     = "SP"
}

variable "public_ip" {
  type        = bool
  default     = false
  description = "should ec2 instance have public ip?"
}

#variable "vpc_id" {
#  default = "
#  description = "VPC ID"
#}


variable "public_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDG4M7O1UbmE8mC26cB4hFwWgNpAJSZHgM7lIuFrtf6rCdOhGDJbouI2GQD01u1the6t1HxGQRc2XwQNo97c4LpYZnxxzZDZRYgMQ78Ng42973Kz5Q2xfu32lmBvds8vZqRyaiNkWYC9AiIPAh/Fau/D/KDVNRun/xjzxPFalK1iarWTW3t8GZyP1MjbS07uvk2PIj/LW3EaW2hSIslUxQE4NSIOki2wqL10oO11SWdhcq4AelGQ6M8c3mLSUG8e/yxO4QxomoOmyTDmj99GXb3kM/Y5BwVqneZfv1IkaQxF4vpsRQc7A/OlhJGCaKKztIXvhTbI4Rj2hGTTcMnoBy9 rsa-key-20230615"
}

variable "key_pair_name" {
  type    = string
  default = "default"
}
