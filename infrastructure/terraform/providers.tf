terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    google = {
      source  = "registry.opentofu.org/hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file("../gcp-key.json")
}
