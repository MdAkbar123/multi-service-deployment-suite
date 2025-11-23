output "public_ip" {
  description = "Public IP of the Docker host"
  value       = aws_instance.docker_host.public_ip
}

output "ecr_api_url" {
  value = aws_ecr_repository.api.repository_url
}

output "ecr_web_url" {
  value = aws_ecr_repository.web.repository_url
}
