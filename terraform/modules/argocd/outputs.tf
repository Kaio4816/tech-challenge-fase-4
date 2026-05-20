output "argocd_namespace" {
  description = "Namespace do ArgoCD"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_release_name" {
  description = "Nome do release Helm do ArgoCD"
  value       = helm_release.argocd.name
}