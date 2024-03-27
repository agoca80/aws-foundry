resource "aws_alb_target_group" "this" {
  name     = local.name
  protocol = "HTTP"
  port     = local.port
  vpc_id   = data.aws_vpc.this.id

  health_check {
    matcher             = "200-299"
    interval            = 30
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    port                = "traffic-port"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }
}

resource "aws_alb_target_group_attachment" "this" {
  target_group_arn = aws_alb_target_group.this.arn
  target_id        = aws_instance.this.id
  port             = local.port
}
