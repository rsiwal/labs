resource "vault_policy" "simple-webapp" {
  name = "simple-webapp"

  policy = <<EOT
path "lab*" {
  capabilities = ["read"]
}
path "secret*" {
  capabilities = ["read"]
}
path "lab/generic/*" {
  capabilities = ["read"]
}
path "internal*" {
  capabilities = ["read"]
}
EOT
}
