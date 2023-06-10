data "aws_vpc" "default" {
  id = var.default_vpc_id
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.default_vpc_id]
  }
}

data "aws_caller_identity" "default" {}