provider "aws" {
  region  = var.region
  profile = "kala"
}

locals {
  tags = {
    project = "million-users"
  }
}

data "aws_subnets" "subnets" {}

output "wordpress" {
  value = {
    wordpress = aws_instance.wordpress.public_ip
  }
}

output "database" {
  value = {
    endpoint = aws_rds_cluster.mysql.endpoint
    name     = aws_rds_cluster.mysql.database_name
    username = aws_rds_cluster.mysql.master_username
    password = "devopsvn"
  }
}
