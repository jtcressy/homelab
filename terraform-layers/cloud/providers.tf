provider "google" {
  region = "us-central1"
}

provider "google-beta" {
  region = "us-central1"
}

provider "zerotier" {}

variable "gh_pat" {}

provider "github" {
  token = var.gh_pat
  owner = "jtcressy"
}