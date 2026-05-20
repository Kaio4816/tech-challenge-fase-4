resource "kubernetes_namespace_v1" "observability" {
  metadata {
    name = "observability"

    labels = {
      "app.kubernetes.io/name"    = "observability"
      "app.kubernetes.io/part-of" = "techchallenge"
    }
  }

  depends_on = [module.eks]
}

resource "kubernetes_secret_v1" "external_apm" {
  metadata {
    name      = "external-apm-secret"
    namespace = kubernetes_namespace_v1.observability.metadata[0].name
  }

  type = "Opaque"

  data = {
    NEW_RELIC_LICENSE_KEY = var.new_relic_license_key
  }

  depends_on = [module.argocd]
}

resource "kubernetes_secret_v1" "incident_integrations" {
  metadata {
    name      = "incident-integrations-secret"
    namespace = kubernetes_namespace_v1.observability.metadata[0].name
  }

  type = "Opaque"

  data = {
    pagerduty_routing_key = var.pagerduty_routing_key
    discord_webhook_url   = var.discord_webhook_url
  }

  depends_on = [module.argocd]
}
