data "aws_vpc" "default" {
  id = var.default_vpc_id
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "igw-1"
    values = [var.default_vpc_id]
  }
}