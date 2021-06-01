locals {
  charts = {
    vault = {
      repository = "https://helm.releases.hashicorp.com/"
      name       = "hashicorp-vault"
      namespace  = "hashicorp-vault-lab"
      chart      = "vault"
      version    = "0.12.0"
      custom_values = {
        "server.dev.enabled"          = false
        "server.ha.enabled"           = false
        "server.auditStorage.enabled" = true
        "server.auditStorage.size"    = "500Mi"
        "server.dataStorage.size"     = "500Mi"
        "server.service.type"         = "NodePort"
        "server.service.nodePort"     = "30082"
      }
    },
    argocd = {
      repository = "https://argoproj.github.io/argo-helm"
      name       = "argocd"
      namespace  = "argocd-lab"
      chart      = "argo-cd"
      version    = "3.6.4"
      custom_values = {
        "server.service.type"          = "NodePort"
        "server.service.nodePortHttps" = "30443"
      }
    },
    haproxy-ingress = {
      repository = "https://haproxytech.github.io/helm-charts"
      name       = "kubernetes-ingress"
      namespace  = "kubernetes-ingress-lab"
      chart      = "kubernetes-ingress"
      version    = "1.15.2"
      custom_values = {
        "controller.kind"                    = "DaemonSet"
        "controller.service.nodePorts.http"  = "31000"
        "controller.service.nodePorts.https" = "31001"
      }
    },
    keycloak = {
      repository = "https://charts.bitnami.com/bitnami"
      name       = "keycloak"
      namespace  = "keycloak-lab"
      chart      = "keycloak"
      version    = "3.0.4"
      custom_values = {
        "postgresql.persistence.size" = "500Mi"
        "auth.adminUser"              = "admin"
        "auth.adminPassword"          = "admin_123"
        "service.type"                = "NodePort"
        "service.nodePorts.https"     = "31443"
      }
    }
  }
}
