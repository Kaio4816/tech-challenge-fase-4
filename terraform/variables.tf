variable "project_name" {
  type    = string
  default = "fase3"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "eks_cluster_name" {
  type    = string
  default = "togmaster-eks"
}

variable "eks_version" {
  type    = string
  default = "1.29"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "db_username" {
  type      = string
  default   = "postgres"
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "redis_node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "ecr_repositories" {
  type = list(string)
  default = [
    "auth-service",
    "flag-service",
    "targeting-service",
    "evaluation-service",
    "analytics-service",
  ]
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes no EKS"
  type        = string
}

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
  default     = "tech-challenger"
}

variable "db_engine_version" {
  type    = string
  default = "16.13"
}
