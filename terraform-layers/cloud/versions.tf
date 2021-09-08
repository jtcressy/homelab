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
    zerotier = {
      source = "zerotier/zerotier"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
  required_version = ">=1.0"
}