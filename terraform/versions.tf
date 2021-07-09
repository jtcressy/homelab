terraform {
  required_providers {
    google-beta = {
      source = "hashicorp/google-beta"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    google = {
      source = "hashicorp/google"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  # required_version = ">=1.0"
  # required_version = ">= 0.13"
  required_version = ">= 0.13"
}