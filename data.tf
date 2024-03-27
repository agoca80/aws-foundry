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

data "aws_ssm_parameter" "image_id" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
