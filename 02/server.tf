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
    content = templatefile("${path.module}/cloud_config.yaml", {
      endpoint          = aws_rds_cluster.mysql.endpoint,
      database_name     = aws_rds_cluster.mysql.database_name,
      master_username   = aws_rds_cluster.mysql.master_username,
      master_password   = aws_rds_cluster.mysql.master_password,
      wp_url            = module.alb_wordpress.lb_dns_name,
      wp_title          = var.wp_title,
      wp_admin_user     = var.wp_admin_user,
      wp_admin_password = var.wp_admin_password,
      wp_admin_email    = var.wp_admin_email,
    })
  }
}

resource "aws_launch_template" "wordpress" {
  depends_on = [
    aws_rds_cluster_instance.mysql
  ]

  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name      = var.ec2_keypair

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = data.cloudinit_config.config.rendered

  tags = {
    "Name" = "WordPress"
  }
}

resource "aws_autoscaling_group" "wordpress" {
  name             = "wordpress"
  min_size         = 1
  desired_capacity = 1
  max_size         = 3

  vpc_zone_identifier = data.aws_subnets.subnets.ids
  target_group_arns   = module.alb_wordpress.target_group_arns

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = aws_launch_template.wordpress.latest_version
  }

  enabled_metrics = [
    "GroupAndWarmPoolDesiredCapacity",
    "GroupAndWarmPoolTotalCapacity",
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingCapacity",
    "GroupPendingInstances",
    "GroupStandbyCapacity",
    "GroupStandbyInstances",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances",
    "WarmPoolDesiredCapacity",
    "WarmPoolMinSize",
    "WarmPoolPendingCapacity",
    "WarmPoolTerminatingCapacity",
    "WarmPoolTotalCapacity",
    "WarmPoolWarmedCapacity",
  ]

  tag {
    key                 = "Name"
    value               = "WordPress"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "wordpress_scaling_policy" {
  name                   = "wordpress-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.wordpress.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50
  }
}
