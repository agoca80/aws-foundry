data "http" "public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  public_ip = jsondecode(data.http.public_ip.response_body)
}

resource "aws_security_group" "this" {
  name   = local.name
  tags   = local.tags
  vpc_id = data.aws_vpc.this.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh" {
  cidr_blocks       = [format("%s/32", local.public_ip.ip)]
  from_port         = 22
  protocol          = "tcp"
  type              = "ingress"
  to_port           = 22
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "internal" {
  cidr_blocks              = [data.aws_vpc.this.cidr_block]
  from_port                = 30000
  protocol                 = "tcp"
  type                     = "ingress"
  to_port                  = 30000
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  from_port         = 0
  protocol          = "-1"
  type              = "egress"
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}
