output "eip"{
    value=aws_eip.nat["public-az1"].id
}

