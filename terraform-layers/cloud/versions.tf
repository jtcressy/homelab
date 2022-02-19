terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~>4.11"
    }
    google = {
      source  = "hashicorp/google"
      version = "~>4.11"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">=1.0"
}