variable "argocd_namespace" {
  description = "Namespace do ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Versão do chart do ArgoCD"
  type        = string
  default     = "7.8.2"
}

variable "argocd_service_type" {
  description = "Tipo do service do ArgoCD"
  type        = string
  default     = "LoadBalancer"
}

variable "argocd_hostname" {
  description = "Hostname opcional do ArgoCD"
  type        = string
  default     = ""
}