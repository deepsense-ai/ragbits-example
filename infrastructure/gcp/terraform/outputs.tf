output "repository_url" {
  description = "The address of the Docker repository"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.name}"
}

output "service_url" {
  description = "The Public URL (Load Balancer IP) of the application"
  value = "http://${google_compute_global_forwarding_rule.forwarding_rule.ip_address}"
}