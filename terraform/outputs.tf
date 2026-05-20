output "vpc_id" {
  value = module.networking.vpc_id
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_role_arn" {
  value = module.eks.cluster_role_arn
}

output "eks_node_role_arn" {
  value = module.eks.node_role_arn
}

output "rds_endpoints" {
  value = module.rds.rds_endpoints
}

output "redis_endpoint" {
  value = module.elasticache.redis_endpoint
}

output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "sqs_queue_url" {
  value = module.sqs.queue_url
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "argocd_namespace" {
  value = module.argocd.argocd_namespace
}

output "argocd_release_name" {
  value = module.argocd.argocd_release_name
}