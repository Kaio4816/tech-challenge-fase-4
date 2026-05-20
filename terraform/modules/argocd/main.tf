resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = {
      app = "argocd"
    }
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false
  version          = var.argocd_chart_version
  timeout          = 900

  values = [
    yamlencode({
      configs = {
        params = {
          "server.insecure" = true
        }
      }

      server = {
        service = {
          type = var.argocd_service_type
        }
      }

      controller = {
        replicas = 1
      }

      repoServer = {
        replicas = 1
      }

      applicationSet = {
        replicas = 1
      }

      redis = {
        enabled = true
      }

      global = {
        domain = var.argocd_hostname != "" ? var.argocd_hostname : null
      }
    })
  ]
}