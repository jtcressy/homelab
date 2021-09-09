resource vault_identity_oidc server {
  issuer = "https://vault.jtcressy.net"
}

resource vault_identity_oidc_key testing {
  name = "testing-key"
  algorithm = "RS256"
}

resource vault_identity_oidc_role testing {
  name = "testing"
  key = vault_identity_oidc_key.testing.name
  template = <<EOF
{
  "entity": {{identity.entity.name}},
  "roles": {{identity.entity.groups.names}},
  "nbf": {{time.now}}
}
EOF
}

resource vault_identity_oidc_key_allowed_client_id testing {
  key_name = vault_identity_oidc_key.testing.name
  allowed_client_id = vault_identity_oidc_role.testing.client_id
}

resource vault_identity_entity joel {
  name     = "joel"
  policies = [vault_policy.admin-all.name]
}

resource vault_identity_entity_alias joel {
  name           = "joel@jtcressy.net"
  mount_accessor = vault_jwt_auth_backend.google-oidc.accessor
  canonical_id   = vault_identity_entity.joel.id
}
