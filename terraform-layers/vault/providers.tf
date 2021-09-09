/*
Vault Bootstrapping Guide
deploy vault, run "vault operator init" and save the output then grab the root_token.
supply this token (or a short-lived orphan token) via "-var=vault_bootstrap_token=<token>"
OR via "TF_VAR_vault_bootstrap_token=<token>" environment variable.
*/
provider "vault" {
  token = var.vault_bootstrap_token
  dynamic "auth_login" {
    for_each = length(var.vault_bootstrap_token) > 0 ? [] : [{
      path = "auth/approle/login"
      parameters = {
        role_id   = var.vault_self_approle_id
        secret_id = var.vault_self_approle_secret
      }
    }]
    content {
      path       = auth_login.value.path
      parameters = auth_login.value.parameters
    }
  }
}
