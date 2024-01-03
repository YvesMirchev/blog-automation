output "instance_public_ips" {
  value = {
    db01            = aws_instance.vprofile_db01.public_ip
    mc01            = aws_instance.vprofile_mc01.public_ip
    rmq01           = aws_instance.vprofile_rmq01.public_ip
    app01           = aws_instance.vprofile_app01.public_ip
    ansible_control = aws_instance.ansible_control.public_ip
  }
}

output "instance_private_ips" {
  value = {
    db01            = aws_instance.vprofile_db01.private_ip
    mc01            = aws_instance.vprofile_mc01.private_ip
    rmq01           = aws_instance.vprofile_rmq01.private_ip
    app01           = aws_instance.vprofile_app01.private_ip
    ansible_control = aws_instance.ansible_control.private_ip
  }
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}
