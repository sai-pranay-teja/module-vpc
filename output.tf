output "eip"{
    value=aws_eip.eip["public_az1"].id
}

