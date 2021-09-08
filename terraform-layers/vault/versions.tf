terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
  }
  required_version = ">=1.0"
}