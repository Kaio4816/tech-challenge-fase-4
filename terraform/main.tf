module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  eks_cluster_name   = var.eks_cluster_name
}

module "eks" {
  source = "./modules/eks"

  project_name        = var.project_name
  environment         = var.environment
  cluster_name        = var.eks_cluster_name
  eks_version         = var.eks_version
  subnet_ids          = module.networking.private_subnet_ids
  vpc_id              = module.networking.vpc_id
  node_instance_types = var.node_instance_types
  desired_size        = var.desired_size
  min_size            = var.min_size
  max_size            = var.max_size
}

module "rds" {
  source = "./modules/rds"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.private_subnet_ids
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  db_engine_version = var.db_engine_version
  vpc_cidr          = var.vpc_cidr
}

module "elasticache" {
  source = "./modules/elasticache"

  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.networking.vpc_id
  subnet_ids      = module.networking.private_subnet_ids
  redis_node_type = var.redis_node_type
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "sqs" {
  source = "./modules/sqs"

  project_name = var.project_name
  environment  = var.environment
}

module "ecr" {
  source = "./modules/ecr"

  repositories = var.ecr_repositories
}

module "argocd" {
  source = "./modules/argocd"

  argocd_namespace     = var.argocd_namespace
  argocd_chart_version = var.argocd_chart_version
  argocd_service_type  = var.argocd_service_type
  argocd_hostname      = var.argocd_hostname

  depends_on = [module.eks]
}