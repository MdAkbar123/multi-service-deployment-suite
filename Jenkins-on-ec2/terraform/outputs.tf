output "instance_id" {
  description = "ID of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.id
}

output "public_ip" {
  description = "Public IP of Jenkins EC2 instance"
  value       = aws_instance.jenkins.public_ip
}

output "public_dns" {
  description = "Public DNS of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.public_dns
}

output "security_group_id" {
  description = "Security group id for Jenkins"
  value       = aws_security_group.jenkins_sg.id
}

output "iam_instance_profile" {
  description = "IAM instance profile attached to the instance"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}
