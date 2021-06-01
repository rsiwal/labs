# Assumes that you have the ~/.kube/config pointing to the correct Kubernetes cluster
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

