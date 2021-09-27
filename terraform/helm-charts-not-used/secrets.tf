#resource "kubernetes_secret" "argocd-repo-server-tls" {
#  metadata {
#    name = "argocd-repo-server-tls"
#    namespace = "argocd-lab"
#  }
#
#  data = {
#    "tls.crt" = "${file("${path.module}/../../../secrets/openssl/argocd.crt")}",
#    "tls.key" = "${file("${path.module}/../../../secrets/openssl/argocd.key")}",
#    "ca.crt" = "${file("${path.module}/../../../secrets/openssl/labs-ca.crt")}"
#  }
#
#  type = "generic"
#}
#
