resource "aws_lb" "alb" {
  name               = local.application_load_balancer_name
  depends_on         = [local.igw]
  internal           = false
  load_balancer_type = "application"
  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
  security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.CERTIFICATE_ARN
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http_target_group.arn
  }
}

resource "aws_lb_target_group" "http_target_group" {
  name     = "${local.application_load_balancer_name}-http-tg"
  port     = local.container_port
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    path = "/health"
  }
}
