terraform {
  required_providers {
    google-beta = {
      source = "hashicorp/google-beta"
    }
    google = {
      source = "hashicorp/google"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">=1.0"
}