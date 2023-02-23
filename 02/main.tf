provider "aws" {
  region  = var.region
}

locals {
  tags = {
    project = "million-users"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "subnets" {}

output "database" {
  value = {
    endpoint = aws_rds_cluster.mysql.endpoint
    name     = aws_rds_cluster.mysql.database_name
    username = aws_rds_cluster.mysql.master_username
    password = "devopsvn"
  }
}

output "alb" {
  value = module.alb_wordpress.lb_dns_name
}