resource "vault_policy" "admin-all" {
  name   = "admin-all"
  policy = data.vault_policy_document.admin-all.hcl
}

data "vault_policy_document" "admin-all" {
  rule {
    path         = "*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
}
