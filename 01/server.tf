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
    content      = templatefile("${path.module}/cloud_config.yaml", {})
  }
}

resource "aws_instance" "wordpress" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name      = "default"

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = data.cloudinit_config.config.rendered
}
