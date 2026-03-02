terraform {
  backend "gcs" {
    prefix      = "prod/ragbits-chat"
  }
}
