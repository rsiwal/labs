resource "helm_release" "helm_release" {
  for_each = local.charts

  version           = each.value["version"]
  repository        = each.value["repository"]
  create_namespace  = true
  name              = each.value["name"]
  chart             = each.value["chart"]
  dependency_update = true
  namespace         = each.value["namespace"]

  dynamic "set" {
    for_each = each.value["custom_values"]

    content {
      name  = set.key
      value = set.value
    }
  }
}
