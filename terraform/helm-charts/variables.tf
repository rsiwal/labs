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
        "server.service.type"                      = "NodePort"
        "server.service.nodePortHttps"             = "30443"
        "configs.secret.argocdServerTlsConfig.key" = base64decode("LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb2dJQkFBS0NBUUVBdUhSbWtZbDJnSisraCtCVHFsWFQ0U1Z1ZUtjc1dnZHIvZmtmYUw2Vk1MN0h1MDdTCmJFV3JRSW9oODNiaGR3NWVQR0hqR1pSOS9VOC9tQkJQNitZak5qN3A2Ty83QncwY0htazlsTmhLZzNXOTRJQXgKVkxoM3lLOGtKcVJ6UHRuT2RjNm9idTJETWxVUzJnblk4VER1MlB6Sk9qMXNVUDJPZTVvSVlvNThqMnJqREhSNApTekMzWDdMTHRLbjlVSmF2M0xMUjFOb3gvckdzSUIzdlovQXMvNlAxZVA3UkV1OW00MHF2NmlQWGJLRXloMjRyCjdwSVBnK2tXMzlOSi9JM245TGhyRGtMU1FXSWd1UUp0L01Zd09tcFpPSWdYWmk4bEE1RHFBQzA3MXFZWGhOTWUKekNXVzBTRTRndDI2UHNiRThKdnZoY092Q095RXUxTzVCbTZxZVFJREFRQUJBb0lCQURyQXdPYjhuU1Z0UEpnMQpLUkVwazNxMG5KS0wxVUc3K1hjRlFpN3YvYjl3RlZpaFM3ODNGY3hSODJ5RVlsNjAwZWx6MkkyT1VlODhyZW4yCjBDNDR1T0NQZTV3NXpJQzdlVWhxaHpZQkN3TUNuditDZGJRaHFlM2ZjNmxuV2xvYnNIcXYzOUN0a011WWM0L0YKOFRjcU9mb2QwczdkUDhJd2NaRUhTRUowVmxLcjA3S08xbmtCbHQrU2JzV2RFbzBGcjgwUWJkekx3K2xBUlZFMwpQM2VXTkloWlNMcHFyc09USlg1aFprWmpRdXVaRGRsMitkOFpTVmlOK0ZOTHJ5ZEUrM1E2MytZM0duNk92NFNNCkwxVGp0MjJ4OTZKZ0d6MGFibkNoVTF3a2RoWTc3ZWZoK05JTS85MFRjQkVjckZ3eVVXNjJsbkZSOXJJbmZZaGgKaGVpMEpZRUNnWUVBNElGMHZCQk1qQW5HeS9aWkw2RzVZR1ROS0Eya09uQTFvV0dFOU1qeDJLRmxjYTZsU2Q4cQpaMmdCdVUrTkEwbHJZUVBoTUZ5YmFsWTh4eEVzSzZXZjBzNjlEQ3V5dGU5eWoyc1YvbUVnTEFVN3FLRW00ako5Clg4OTVTYXZOamo1SDA0RXo4U1RwdWxoUk4wUmVpcUNCdXM5NEZHWFhUWE45K2diYjdxVnA0dEVDZ1lFQTBsU2QKdk12THRJTksvL25SNWlYRXFic0dTUEZwK3VFNVZYOG0xWi9MYkNQbGwyZEVvUU9BYUZQcnFzSERyMFozMEovaApxR2tmeUtKUnduM3lYN3FlUFJBNDlNcm9Hc2R0M2tFSnp2ZkZhREwxTlBXRWJ1bElvUUEreFh0dllvSjZURnNKCmppcWdlK3V4YXdLRTlORUZGeEVwRnk0WVR3bzI3a2t5MnFBVHB5a0NnWUJJVW12QWlaK2ZIU2NsWFY2dHNYTisKVWZxbEJILzdNMXFUZWs3U2JFazhlQUd0OVl6WmwwS1p2UytRK3NkNlg1UnYxRWdleERac3N3c3hOWjc5RUlYRAo2MFdMUGloNzQzOE1KSHNaVDBDRjdjbWlNUWZOcG1ZdER6RUxRb1VkWllMTjU3bEwzWkJOcjFXNmNCUGtwSUFtCkpkK1E4cDNCSFl0Zm1BWVJnc2Z4Z1FLQmdHQzBMdUlEQVdHNWk5NHRTbWg2clBVczNETGxiRWpCRE05V2F0Q0YKYTg0SW95TDlnL3hUMDlJajQ1TGJDOUdtb0tmM0dwV0gzK2tyV0ZRSC9Fd3ZUVm5kLzVIdFNOSW5KMGlzdG9uRwpPYWt5NUxLNHYyOFBLeWw3SjJFODQzVnpjQzl6RysyVmc3djJIZGlKaS8vVHFuZDBtR1BqK2FFOW5RdnA4OHU1CkZkQWhBb0dBTG5UYVA2STFhNTQ1Y1RmeFl2bE5hU1pUNFcvemR1Q0hCWkNJS3JJcmNLNENLUlRkd3ZSc1F1YngKaDYwcTB5bHk0RmNNU05EeW1WNlNrbVNUcDBRQU9keCtYRmZuQWFtQi9aSWQ4dXZrQXdWcGo1NGE5Q21RZ0tvcgozRTJtUFVBbkJjZVB1ci9sQnJjZThHMUl3NkE4RnhCQTg2OEIxSVl6SG5LdW9UQ2pKQkU9Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==")
        "configs.secret.argocdServerTlsConfig.crt" = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURwVENDQW8yZ0F3SUJBZ0lCQWpBTkJna3Foa2lHOXcwQkFRc0ZBREJVTVFzd0NRWURWUVFHRXdKSlRqRVYKTUJNR0ExVUVDQXdNUlhoaGJYQnNaVk4wWVhSbE1SVXdFd1lEVlFRS0RBeEZlR0Z0Y0d4bElFbHVZeTR4RnpBVgpCZ05WQkFNTURtTmhMbVY0WVcxd2JHVXVZMjl0TUNBWERUSXhNRGt5TnpBMU5UYzBPRm9ZRHpJeE1qRXdPVEF6Ck1EVTFOelE0V2pCWk1Rc3dDUVlEVlFRR0V3SkpUakVWTUJNR0ExVUVDQXdNUlhoaGJYQnNaVk4wWVhSbE1SVXcKRXdZRFZRUUtEQXhGZUdGdGNHeGxJRWx1WXk0eEhEQWFCZ05WQkFNTUUyRnlaMjh0WTJRdVpYaGhiWEJzWlM1agpiMjB3Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLQW9JQkFRQzRkR2FSaVhhQW43Nkg0Rk9xClZkUGhKVzU0cHl4YUIydjkrUjlvdnBVd3ZzZTdUdEpzUmF0QWlpSHpkdUYzRGw0OFllTVpsSDM5VHorWUVFL3IKNWlNMlB1bm83L3NIRFJ3ZWFUMlUyRXFEZGIzZ2dERlV1SGZJcnlRbXBITSsyYzUxenFodTdZTXlWUkxhQ2RqeApNTzdZL01rNlBXeFEvWTU3bWdoaWpueVBhdU1NZEhoTE1MZGZzc3UwcWYxUWxxL2NzdEhVMmpIK3Nhd2dIZTluCjhDei9vL1Y0L3RFUzcyYmpTcS9xSTlkc29US0hiaXZ1a2crRDZSYmYwMG44amVmMHVHc09RdEpCWWlDNUFtMzgKeGpBNmFsazRpQmRtTHlVRGtPb0FMVHZXcGhlRTB4N01KWmJSSVRpQzNibyt4c1R3bSsrRnc2OEk3SVM3VTdrRwpicXA1QWdNQkFBR2plekI1TUFrR0ExVWRFd1FDTUFBd0xBWUpZSVpJQVliNFFnRU5CQjhXSFU5d1pXNVRVMHdnClIyVnVaWEpoZEdWa0lFTmxjblJwWm1sallYUmxNQjBHQTFVZERnUVdCQlNVUU1yNU1tclYvS2Zrbm1FeUptYS8KeU9CMkpqQWZCZ05WSFNNRUdEQVdnQlRsalVJRk55N0J0c0VTZVdxYVNzb0pLeHBGdkRBTkJna3Foa2lHOXcwQgpBUXNGQUFPQ0FRRUFCMDNFK1preklWeFRjMnlqbHNHWk0xUkUvbXNnVXk0MjZ2VTczZlBSU3Z3dlFsYit2TVN4CkR1bkZ0cHlBbG0vT0g5Wm9wMzBzRUhVb0ovZW11bWN1aGlTVzhTaEJEbEs0VWlCNEt3bGVlNHFOUExubDA5RnkKamxjTkVPbWllcEVhYXBTQVU2eEsvZWRMRUdabVhIMlhVUFZvUmcvVHdjSmo2cndFcVVCQVBWUFIxNjRQaVFpVQpuOE42amkzREJhK0UwWWt2d2FJWTJtVGl1ZURDbVR5b1AwQkV2R1FlaThlajd1WXBHQUpqT3l1bld3ZWdvdWN1CnBVWkZibVh0Qjl4RnZPWm1QRVUwQ0J6SmtNclNvM3pxMWNnUC9GMDFTODgrZUp4NHl1Z29CbTgzZU15RXVxdHQKVUI2ZWl0blBUOTJIRlJIOENRU0l3cFBuaXM3amVwdXpPdz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0KLS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURpekNDQW5PZ0F3SUJBZ0lVWUZkVUsvM25mNUNUU1JsSEo1T3lGS2NIUUpNd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1ZERUxNQWtHQTFVRUJoTUNTVTR4RlRBVEJnTlZCQWdNREVWNFlXMXdiR1ZUZEdGMFpURVZNQk1HQTFVRQpDZ3dNUlhoaGJYQnNaU0JKYm1NdU1SY3dGUVlEVlFRRERBNWpZUzVsZUdGdGNHeGxMbU52YlRBZ0Z3MHlNVEE1Ck1qSXdNakU0TXpkYUdBOHpNREl4TURFeU16QXlNVGd6TjFvd1ZERUxNQWtHQTFVRUJoTUNTVTR4RlRBVEJnTlYKQkFnTURFVjRZVzF3YkdWVGRHRjBaVEVWTUJNR0ExVUVDZ3dNUlhoaGJYQnNaU0JKYm1NdU1SY3dGUVlEVlFRRApEQTVqWVM1bGVHRnRjR3hsTG1OdmJUQ0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCCkFPSEdBajdlQm1BUSsxVWFMaTFFMllyUGlvK1B2eVIvb2ROTktyWVROWGhUMUlHSDBlQU1Hb2xzOTc5eEdqYXQKbnRrM3dWRlhiMXFBOU1DTXFuaHpHZTRyYmdRY1hkL0JHb1ZpRXEyOTRXL3dkQk5NeEJ3cEhtK0hGMlp4c290Vgpoek4xNlJhL2QvcDdVcTNkWjFCeUZvSU9jeCtNY09WMmJnWUFrMlJlMU9vVUx0eEpMZjhnQjNwQmN6MDRKN0M1CnJEYXJMdkgrUEswVFFKZDhleDVmSDdtWGg3aDd2VHdwSnpxMDZ6VHVPdTFHRGx5L0ZnMC9uVXBWQWQvUkRNanQKcWdBTGJRV1dUZ3ZUNDZ0M1RxSTBPOVA3V1dMZDI0bXVMN3IxcVVjeFBFWXpvODlGM2NVSEUvKzY1VnBPaWFCUgpTdTlQZlA3amFFcVZaYlF1YVRKeGk5VUNBd0VBQWFOVE1GRXdIUVlEVlIwT0JCWUVGT1dOUWdVM0xzRzJ3Uko1CmFwcEt5Z2tyR2tXOE1COEdBMVVkSXdRWU1CYUFGT1dOUWdVM0xzRzJ3Uko1YXBwS3lna3JHa1c4TUE4R0ExVWQKRXdFQi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFLMlprbTEwc3Rhdmo4UUYySkJ4RWFsRgpmWllGak5tVS9yVlZDZ3NPVkhuWEdNVGVCL0hxdUhtdENqOXlncS9JVWhUR1RXcjJTSXRiYklmRXVXZ3dkQ2R1CmhveENuS0Q0c1NLOXByS0pqTE5BL09PNzVZWERCUFNjV1VCVEV0UnIrS3JFUHpnNlFDR29xSnA5LzgxREQ1cVYKT01Xb1FXdHR2Z0twVm40MHJUN1JTSFVNaVY4M1RNNWRvWEV5YW56R09PM25rWVowVTZVZGFCa01Lejd1L1grRQpYck53czB6SHdpSFFHYjZ1MlZaK3F2d0xHV3lXSENOaS90VFc5VzFNeWNINFFsZHd6c0JxUHQxMldJeG5vZWhoCk5VczcwK1Y0b3hVYlh1WTdoMllGQnhMN0JQZ1dWNVhycmd0d3ZXNlZEeVZmeXRmN0hlUnNnM0t1SVRwcUVEaz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=")
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
    prometheus-blackbox-exporter = {
      repository = "https://prometheus-community.github.io/helm-charts"
      name       = "prometheus-blackbox-exporter"
      namespace  = "prometheus-blackbox-exporter"
      chart      = "prometheus-blackbox-exporter"
      version    = "5.0.3"
      custom_values = {
      }
    }
    prometheus-pingdom-exporter = {
      repository = "https://prometheus-community.github.io/helm-charts"
      name       = "prometheus-pingdom-exporter"
      namespace  = "prometheus-pingdom-exporter"
      chart      = "prometheus-pingdom-exporter"
      version    = "2.4.1"
      custom_values = {
      }
    }
    prometheus-mysql-exporter = {
      repository = "https://prometheus-community.github.io/helm-charts"
      name       = "prometheus-mysql-exporter"
      namespace  = "prometheus-mysql-exporter"
      chart      = "prometheus-mysql-exporter"
      version    = "1.2.2"
      custom_values = {
      }
    }

  }
}
