data "aws_vpc" "this" {
  filter {
    name   = "tag:Environment"
    values = [local.environment]
  }
}

data "aws_subnet" "this" {
  availability_zone = local.availability_zone
  vpc_id            = data.aws_vpc.this.id

  tags = {
    Environment = local.environment
    Public      = "true"
  }
}
