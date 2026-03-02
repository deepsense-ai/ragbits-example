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
  
  # block direct internet access, force traffic through the LB
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER" 

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

# allow public access at the IAM level (WAF does the blocking)
resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.app.location
  project  = google_cloud_run_v2_service.app.project
  service  = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# firewall rules
resource "google_compute_security_policy" "policy" {
  name = "${var.app_name}-security-policy"

  rule {
    action   = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = [var.my_ip]
      }
    }
    description = "Allow deployment machine IP"
  }

  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default deny all"
  }
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "${var.app_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_v2_service.app.name
  }
}

resource "google_compute_backend_service" "backend" {
  name                  = "${var.app_name}-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = google_compute_security_policy.policy.id

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
}

resource "google_compute_url_map" "url_map" {
  name            = "${var.app_name}-url-map"
  default_service = google_compute_backend_service.backend.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "${var.app_name}-http-proxy"
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name                  = "${var.app_name}-forwarding-rule"
  target                = google_compute_target_http_proxy.http_proxy.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}