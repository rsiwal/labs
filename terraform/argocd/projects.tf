resource "argocd_project" "lab" {
  metadata {
    name      = "argocd-lab-project-1"
    namespace = "argo-cd"
    labels = {
      acceptance = "true"
    }
    annotations = {
    }
  }
  spec {
    description  = "My Lab Project 1"
    source_repos = ["*"]

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "argo-cd"
    }
    orphaned_resources {
      warn = true

      ignore {
        group = "apps/v1"
        kind  = "Deployment"
        name  = "ignored1"
      }

      ignore {
        group = "apps/v1"
        kind  = "Deployment"
        name  = "ignored2"
      }
    }
  }
}

