output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.tf_web_server.public_ip
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.tf_web_server.private_ip
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.tf_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.tf_public_subnet.id
}

output "security_group_id" {
  value = aws_security_group.tf_ec2_sg.id
}
