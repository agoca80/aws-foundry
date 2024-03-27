locals {
  associate_public_ip_address = true
  availability_zone           = var.availability_zone
  environment                 = var.environment
  instance_profile            = null
  instance_type               = "t3a.medium"
  name                        = "foundry"
  port                        = 30000

  block_device_mappings = {
    "/dev/xvda" = {}
    "/dev/xvdb" = {}
  }

  user_data = base64encode(templatefile("${path.module}/user_data.yaml", {
  }))

  tags = merge(var.tags, {
    "Module" = "foundry"
  })
}
