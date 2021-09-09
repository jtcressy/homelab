resource "vault_mount" "meta-config-kv" {
  path = "meta-config"
  type = "kv-v2"
}

resource "vault_generic_secret" "meta-google-oidc-client" {
  path = "${vault_mount.meta-config-kv.path}/vault-google-oidc-client-creds"
  data_json = jsonencode({
    client_id     = ""
    client_secret = ""
  })
  lifecycle {
    ignore_changes = [data_json]
  }
}
