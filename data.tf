data "aws_ebs_volume" "this" {
  filter {
    name   = "tag:Name"
    values = [var.name]
  }

  filter {
    name   = "tag:Purpose"
    values = ["data"]
  }
}

data "aws_ssm_parameter" "image_id" {
  name = "/aws/service/debian/release/bookworm/latest/amd64"
}

data "aws_ssm_parameter" "vpc_id" {
  name = format("/environment/%s/vpc_id", var.environment)
}

data "aws_subnet" "this" {
  availability_zone = local.availability_zone
  vpc_id            = data.aws_vpc.this.id

  tags = {
    Environment = local.environment
    Public      = "true"
  }
}

data "aws_vpc" "this" {
  id = data.aws_ssm_parameter.vpc_id.value

  filter {
    name   = "tag:Environment"
    values = [local.environment]
  }
}
