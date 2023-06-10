output "subnet"{
    value=aws_subnet.public_subnets["public_az1"].id
}

