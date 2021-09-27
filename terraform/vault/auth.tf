resource "vault_auth_backend" "this" {
  for_each = local.auth_methods

  type        = each.value["type"]
  path        = each.value["path"]
  description = each.value["description"]

  tune {
    max_lease_ttl      = each.value["max_lease_ttl"]
    default_lease_ttl  = each.value["default_lease_ttl"]
    listing_visibility = each.value["listing_visibility"]
  }
}
