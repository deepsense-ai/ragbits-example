terraform {
  backend "s3" {
    key = "prod/ragbits-chat/terraform.tfstate"
    # bucket and region are injected via bash script
  }
}