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

resource "vault_mount" "generic-kv" {
  path = "generic"
  type = "kv-v2"
}

resource "vault_generic_secret" "tailscale" {
  path = "${vault_mount.generic-kv.path}/tailscale"
  data_json = jsonencode({
    ephemeral = ""
    reusable = ""
    api = ""
  })
  lifecycle {
    ignore_changes = [data_json]
  }
}