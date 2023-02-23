resource "aws_db_subnet_group" "mysql" {
  name       = "mysql"
  subnet_ids = data.aws_subnets.subnets.ids

  tags = local.tags
}

resource "aws_rds_cluster" "mysql" {
  cluster_identifier = "mysql-cluster"
  engine             = "aurora-mysql"
  engine_version     = "5.7.mysql_aurora.2.10.2"

  database_name   = "devopsvn"
  master_username = "devopsvn"
  master_password = "devopsvn"

  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot         = true
  allow_major_version_upgrade = true
  apply_immediately           = true

  lifecycle {
    ignore_changes = [
      availability_zones,
    ]
  }

  tags = local.tags
}

resource "aws_rds_cluster_instance" "mysql" {
  cluster_identifier = aws_rds_cluster.mysql.id
  engine             = aws_rds_cluster.mysql.engine
  engine_version     = aws_rds_cluster.mysql.engine_version
  identifier         = "mysql-instance-01"
  instance_class     = "db.t3.small"

  performance_insights_enabled = false
  publicly_accessible          = true

  tags = local.tags
}
