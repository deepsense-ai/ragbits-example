resource "google_secret_manager_secret" "api_key" {
  secret_id = "openai-api-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "secret_access" {
  secret_id = google_secret_manager_secret.api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.chat_runner.email}"
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "${var.app_name}-repo"
  description   = "Docker repository for ${var.app_name}"
  format        = "DOCKER"
}

resource "google_service_account" "chat_runner" {
  account_id   = "${var.app_name}-sa"
  display_name = "Identity for ${var.app_name}"
}

resource "google_cloud_run_v2_service" "app" {
  name     = var.app_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.chat_runner.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.name}/${var.app_name}:${var.image_tag}"
      
      env {
        name = "OPENAI_API_KEY"
        value_source {
          secret_key_ref {
            secret  = "openai-api-key"
            version = "latest"
          }
        }
      }
    }
  }
}
