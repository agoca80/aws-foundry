resource "aws_launch_template" "this" {
  image_id                             = data.aws_ssm_parameter.image_id.value
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = local.instance_type
  key_name                             = "access"
  name                                 = local.name
  tags                                 = local.tags
  user_data                            = local.user_data

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  dynamic "iam_instance_profile" {
    for_each = local.instance_profile != null ? [1] : []
    content {
      name = local.instance_profile
    }
  }

  instance_market_options {
    market_type = "spot"
  }

  network_interfaces {
    associate_public_ip_address = local.associate_public_ip_address
    subnet_id                   = data.aws_subnet.this.id
    security_groups             = [aws_security_group.this.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }
}

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

resource "aws_instance" "this" {
  count = local.deploy

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}

resource "aws_volume_attachment" "this" {
  count = local.deploy

  device_name = "/dev/xvdb"
  instance_id = aws_instance.this[0].id
  volume_id   = data.aws_ebs_volume.this.id
}

resource "aws_alb_target_group_attachment" "this" {
  count = local.deploy

  target_group_arn = aws_alb_target_group.this.arn
  target_id        = aws_instance.this[0].id
  port             = local.port
}
