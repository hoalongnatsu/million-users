data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.*-x86_64-gp2"]
  }

  owners = ["137112412989"] # Canonical
}

data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/cloud_config.yaml", {
      endpoint = aws_rds_cluster.mysql.endpoint,
      database_name = aws_rds_cluster.mysql.database_name,
      master_username = aws_rds_cluster.mysql.master_username,
      master_password = aws_rds_cluster.mysql.master_password
    })
  }
}

resource "aws_instance" "wordpress" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name      = var.ec2_keypair

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data_base64 = data.cloudinit_config.config.rendered

  tags = {
    "Name" = "WordPress"
  }
}
