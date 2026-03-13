output "service_url" {
  description = "The URL of the App Runner service"
  value       = "https://${aws_apprunner_service.app.service_url}"
}

output "repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.repo.repository_url
}