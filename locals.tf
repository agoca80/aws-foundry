locals {
  associate_public_ip_address = true
  availability_zone           = data.aws_ebs_volume.this.availability_zone
  deploy                      = var.config.deploy ? 1 : 0
  environment                 = var.environment
  instance_profile            = null
  instance_type               = "t3a.medium"
  name                        = "foundry"
  port                        = 30000

  user_data = base64encode(templatefile("${path.module}/user_data.yaml", {
    VERSION = var.config.version
    WORLD   = var.config.world
  }))

  tags = merge(var.tags, {
    "Module" = "foundry"
  })
}
