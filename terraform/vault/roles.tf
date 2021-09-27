resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = vault_auth_backend.this["kubernetes"].path
  role_name                        = "simple-webapp"
  bound_service_account_names      = ["simple-webapp"]
  bound_service_account_namespaces = ["simple-webapp-lab"]
  token_ttl                        = 3600
  token_policies                   = ["simple-webapp"]
  audience                         = "vault"
}

resource "vault_kubernetes_auth_backend_role" "myapp" {
  backend                          = vault_auth_backend.this["kubernetes"].path
  role_name                        = "myapp"
  bound_service_account_names      = ["nginx"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = ["simple-webapp"]
  #audience                         = "vault"
}

