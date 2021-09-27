locals {
  argocd_namespace = "argo-cd"
  applications = {
    simple-webapp = {
      name            = "simple-webapp"
      namespace       = "simple-webapp-lab"
      repo_url        = "https://github.com/rsiwal/labs"
      path            = "helm-charts/simple-webapp"
      target_revision = ""
      helm_parameters = {
        "image.tag" = "latest"
      }
      destination_k8s_clusters = {
        lab = {
          server    = "https://kubernetes.default.svc"
          namespace = "simple-webapp-lab"
        }
      }
      sync_policy_automated_prune       = true
      sync_policy_automated_self_heal   = true
      sync_policy_automated_allow_empty = true
    }
  }
}

resource "argocd_application" "application" {
  for_each = local.applications

  metadata {
    name      = each.value["name"]
    namespace = local.argocd_namespace
    labels = {
    }
  }

  wait = true

  spec {
    source {
      repo_url        = each.value["repo_url"]
      path            = each.value["path"]
      target_revision = each.value["target_revision"]

      helm {
        dynamic "parameter" {
          for_each = each.value["helm_parameters"]

          content {
            name  = parameter.key
            value = parameter.value
          }

        }

        release_name = each.key
      }
    }

    dynamic "destination" {
      for_each = each.value["destination_k8s_clusters"]

      content {
        server    = destination.value["server"]
        namespace = destination.value["namespace"]
      }
    }


    sync_policy {
      automated = {
        prune       = lookup(each.value, "sync_policy_automated_prune", false)
        self_heal   = lookup(each.value, "sync_policy_automated_self_heal", true)
        allow_empty = lookup(each.value, "sync_policy_automated_allow_empty", true)
      }
      # Only available from ArgoCD 1.5.0 onwards
      sync_options = lookup(each.value, "sync_options", ["Validate=true"])
      retry {
        limit = "5"
        backoff = {
          duration     = "30s"
          max_duration = "2m"
          factor       = "2"
        }
      }
    }
  }
}
