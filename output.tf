/* output "nat"{
    value=aws_nat_gateway.nat["public-az1"]
} */

output "vpc_id"{
    value=aws_vpc.main.id
}

output "public_subnets"{
    value=aws_subnet.public_subnets
}

output "private_subnets"{
    value=aws_subnet.private_subnets
}

output "default_subnets"{
    value=aws_subnet.default_public_subnets
}