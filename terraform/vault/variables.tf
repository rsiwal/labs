locals {
  auth_methods = {
    kubernetes = {
      type               = "kubernetes"
      path               = "kubernetes"
      description        = "Kubernetes Authentication"
      default_lease_ttl  = "1h"
      max_lease_ttl      = "24h"
      listing_visibility = "unauth"
    }
    github = {
      type               = "github"
      path               = "github"
      description        = "GitHub Authentication"
      default_lease_ttl  = "1h"
      max_lease_ttl      = "24h"
      listing_visibility = "unauth"
    }
  }
  engines = {
    "lab-generic" = {
      type        = "generic"
      path        = "lab/generic/"
      description = "Generic Secret"
    },
    "lab-kvv2" = {
      type        = "kv-v2"
      path        = "lab/kvv2"
      description = "QA KV Version2 secret mount. Maintains older versions "
    },
    "lab-pki" = {
      type        = "pki"
      path        = "lab/pki"
      description = "QA PKI secret mount"
    },
    "lab-ssh" = {
      type        = "ssh"
      path        = "lab/ssh"
      description = "SSH secret mount"
    }
  }
}
