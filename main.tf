data "aws_ssm_parameter" "image_id" {
  name = "/aws/service/debian/release/bookworm/latest/amd64"
}

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

resource "aws_instance" "this" {
  count = var.deploy ? 1 : 0

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}

resource "aws_volume_attachment" "this" {
  count = var.deploy ? 1 : 0

  device_name = "/dev/xvdb"
  instance_id = aws_instance.this[0].id
  volume_id   = data.aws_ebs_volume.this.id
}
