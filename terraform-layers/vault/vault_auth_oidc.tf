resource vault_jwt_auth_backend "google-oidc" {
  path               = "google-oidc"
  type               = "oidc"
  oidc_discovery_url = "https://accounts.google.com"
  oidc_client_id     = vault_generic_secret.meta-google-oidc-client.data.client_id
  oidc_client_secret = vault_generic_secret.meta-google-oidc-client.data.client_secret
  bound_issuer       = "https://accounts.google.com"
  default_role       = "default"
  tune {
    listing_visibility = "unauth"
    default_lease_ttl = "168h"
    max_lease_ttl = "720h"
    token_type = "default-service"
    passthrough_request_headers = []
    allowed_response_headers = []
    audit_non_hmac_request_keys = []
    audit_non_hmac_response_keys = []
  }
  lifecycle {
    ignore_changes = [oidc_client_secret]
  }
}

resource vault_jwt_auth_backend_role google-oidc-default {
  backend   = vault_jwt_auth_backend.google-oidc.path
  role_type = "oidc"
  role_name = "default"
  bound_claims = {
    hd = "jtcressy.net"
  }
  user_claim              = "email"
  oidc_scopes             = ["email", "openid"]
  token_no_default_policy = true
  token_policies          = []
  allowed_redirect_uris = [
    "https://vault.jtcressy.net/ui/vault/auth/${vault_jwt_auth_backend.google-oidc.path}/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]
  token_ttl     = 86400
  token_max_ttl = 86400
}
