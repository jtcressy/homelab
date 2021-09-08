variable "vault_bootstrap_token" {
  default     = ""
  description = "Generate a short-lived orphan token from vault using your initial root token and use it here to bootstrap vault"
}
variable "vault_self_approle_id" {}
variable "vault_self_approle_secret" {}
