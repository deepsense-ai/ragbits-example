terraform {
  backend "gcs" {
    prefix      = "prod/ragbits-chat"
    credentials = "../gcp-key.json"
  }
}
