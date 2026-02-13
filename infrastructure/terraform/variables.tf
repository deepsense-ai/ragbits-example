variable "project_id" {
  description = "Ragbits example deployment project"
  type        = string
}

variable "region" {
  description = "GCP Region for deployment"
  type        = string
  default     = "europe-central2"
}

variable "app_name" {
  description = "Name of the application/service"
  type        = string
  default     = "ragbits-chat"
}

variable "image_tag" {
  description = "The Docker image tag to deploy (e.g., 'latest' or a specific version)"
  type        = string
  default     = "latest"
}
