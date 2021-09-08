terraform {
  backend "remote" {
    organization = "jtcressy"
    workspaces {
      name = "homelab"
    }
  }
}