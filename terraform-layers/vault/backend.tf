terraform {
  backend "gcs" {
    bucket = "terraform-state-jtcressy-net"
    prefix = "homelab/vault"
  }
}