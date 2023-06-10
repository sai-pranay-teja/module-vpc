resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "${var.env}-Roboshop-VPC"
  }
}

resource "aws_vpc_peering_connection" "main" {
  #peer_owner_id = var.peer_owner_id
  peer_vpc_id   = aws_vpc.main.id
  vpc_id        = data.aws_vpc.default.id
  auto_accept   = true

  tags = {
    Name = "${var.env}-Roboshop-VPC-peering-connection"
  }
}

resource "aws_subnet" "public_subnets" {
    for_each = var.public_cidr
    vpc_id     = aws_vpc.main.id
    availability_zone = each.value["availability_zone"]
    cidr_block = each.value["cidr"]
    tags={
        Name="${var.env}-${each.value["name"]}-subnet"
    }
}

resource "aws_subnet" "private_subnets" {
    for_each = var.private_cidr
    vpc_id     = aws_vpc.main.id
    availability_zone = each.value["availability_zone"]
    cidr_block = each.value["cidr"]
    tags={
        Name="${var.env}-${each.value["name"]}-subnet"
    }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-Internet-gateway"
  }
}

resource "aws_route_table" "default_rt" {
  vpc_id = data.aws_vpc.default.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block        = var.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }

  tags = {
    Name = "${var.env}-default-public-routetable"
  }
}

resource "aws_subnet" "default_public_subnets" {
    vpc_id     = data.aws_vpc.default.id
    cidr_block = data.aws_vpc.default.cidr_block
    tags={
        Name="Default_subnet"
    }
}

resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.default_public_subnets.id
  route_table_id = aws_route_table.default_rt.id
}


resource "aws_eip" "eip" {
    #vpc=true
    for_each = var.public_cidr
    domain   = "vpc"
    
    tags = {
        Name = "${var.env}-${each.value["name"]}-Elastic-IP"
    }
}

resource "aws_nat_gateway" "nat" {
    for_each = var.public_cidr
    allocation_id = aws_eip.eip[each.value["name"]].id
    subnet_id     = aws_subnet.public_subnets[each.value["name"]].id
    
    tags = {
        Name = "${var.env}-${each.value["name"]}-NAT-Gateway"
    }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip]
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block        = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }
  for_each = var.public_cidr
  tags = {
    Name = "${var.env}-${each.value["name"]}-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
    for_each = var.public_cidr
    subnet_id      = aws_subnet.public_subnets[each.value["name"]].id
    route_table_id = aws_route_table.public_rt[each.value["name"]].id
}


resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.value["name"]].id
  }

  route {
    cidr_block        = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }
  for_each = var.private_cidr
  tags = {
    Name = "${var.env}-${each.value["name"]}-route-table"
  }
}
resource "aws_route_table_association" "private_subnet_assoc" {
    for_each = var.private_cidr
    subnet_id      = aws_subnet.private_subnets[each.value["name"]].id
    route_table_id = aws_route_table.private_rt[each.value["name"]].id
}
