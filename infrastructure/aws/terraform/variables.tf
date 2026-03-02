variable "region" {
  type = string
}

variable "app_name" {
  type    = string
  default = "ragbits-chat"
}

variable "my_ip" {
  description = "dynamically fetched public IP address for setting up the firewall rule in App Runner"
  type        = string
}