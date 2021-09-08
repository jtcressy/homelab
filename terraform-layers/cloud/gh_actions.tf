data "github_actions_public_key" "homelab" {
  repository = "homelab"
}

resource "github_actions_secret" "zerotier_public" {
  repository      = "homelab"
  secret_name     = "ZEROTIER_IDENTITY_PUBLIC"
  plaintext_value = zerotier_identity.gh_actions.public_key
}

resource "github_actions_secret" "zerotier_private" {
  repository      = "homelab"
  secret_name     = "ZEROTIER_IDENTITY_SECRET"
  plaintext_value = zerotier_identity.gh_actions.private_key
}