locals {
  charts = {
    vault = {
      repository = "https://helm.releases.hashicorp.com/"
      name       = "hashicorp-vault"
      namespace  = "hashicorp-vault"
      chart      = "vault"
      version    = "0.16.0"
      custom_values = {
        "server.dev.enabled"          = false,
        "server.ha.enabled"           = false,
        "server.auditStorage.enabled" = true,
        "server.auditStorage.size"    = "500Mi",
        "server.dataStorage.size"     = "500Mi"
      }
    },
    jenkins = {
      repository = "https://charts.jenkins.io"
      name       = "jenkins"
      namespace  = "jenkins"
      chart      = "jenkins"
      version    = "3.5.18"
      custom_values = {
      }
    },
    argo-cd = {
      repository = "https://argoproj.github.io/argo-helm"
      name       = "argo-cd"
      namespace  = "argo-cd"
      chart      = "argo-cd"
      version    = "3.21.0"
      custom_values = {
        "server.service.type"          = "NodePort"
        "server.service.nodePortHttps" = "30443"
      }
    },
    sealed-secrets = {
      repository = "https://bitnami-labs.github.io/sealed-secrets"
      name       = "sealed-secrets"
      namespace  = "sealed-secrets"
      chart      = "sealed-secrets"
      version    = "1.16.1"
      custom_values = {
        "ingress.enabled"  = "true"
        "ingress.hosts[0]" = "sealed-secrets.example.com"
      }
    }
  }
}
