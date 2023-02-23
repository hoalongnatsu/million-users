module "alb_wordpress" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "wordpress"

  load_balancer_type = "application"

  vpc_id          = data.aws_vpc.default.id
  subnets         = data.aws_subnets.subnets.ids
  security_groups = [aws_security_group.alb_wordpress.id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name_prefix      = "web",
      backend_protocol = "HTTP",
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  tags = local.tags
}