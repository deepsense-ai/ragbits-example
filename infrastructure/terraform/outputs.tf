output "repository_url" {
  description = "The address of the Docker repository"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.name}"
}

output "service_url" {
  description = "The public URL of the chat service"
  value       = google_cloud_run_v2_service.app.uri
}
