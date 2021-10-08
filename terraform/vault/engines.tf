resource "vault_mount" "engine" {
  for_each = local.engines

  path        = each.value["path"]
  type        = each.value["type"]
  description = each.value["description"]
}
