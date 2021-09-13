resource "vault_auth_backend" "gcp" {
  path = "gcp"
  type = "gcp"
}

resource "vault_gcp_auth_backend_role" "github-actions" {
  backend                = vault_auth_backend.gcp.path
  role                   = "github-actions"
  type                   = "iam"
  bound_projects         = ["jtcressy-net-235001"]
  bound_service_accounts = ["github-actions@jtcressy-net-235001.iam.gserviceaccount.com"]
  token_policies         = ["default", "admin-all"]
}
