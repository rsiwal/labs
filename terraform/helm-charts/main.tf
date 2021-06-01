resource "helm_release" "releases" {
  for_each = local.charts

  repository       = each.value["repository"]
  name             = each.value["name"]
  chart            = each.value["chart"]
  version          = each.value["version"]
  namespace        = each.value["namespace"]
  create_namespace = true

  dynamic "set" {
    for_each = each.value["custom_values"]

    content {
      name  = set.key
      value = set.value
    }
  }
}