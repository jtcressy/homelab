# data cloudflare_ip_ranges current {}

data "google_compute_network" "default_us-central1" {
  name = "default"
}

data "google_project" "current" {}
data "google_client_config" "current" {}
data "google_compute_zones" "current" {}
