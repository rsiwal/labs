terraform {
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = "1.2.1"
    }
  }
}

provider "argocd" {
  # Configuration options pulled from environment variables
  # ARGOCD_AUTH_USERNAME=admin
  # ARGOCD_INSECURE=false
  # ARGOCD_AUTH_PASSWORD=xxxxxxxxxxx
  # ARGOCD_SERVER=argo-cd.example.com:30443

  # You may user ARGOCD_AUTH_TOKEN instead of ARGOCD_AUTH_USERNAME and ARGOCD_AUTH_PASSWORD
  # ARGOCD_AUTH_TOKEN
}
