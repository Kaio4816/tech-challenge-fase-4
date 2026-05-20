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
  vpc_cidr        = var.vpc_cidr
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

resource "null_resource" "argocd_bootstrap_apps" {
  triggers = {
    project = filesha256("${path.root}/../gitops/argocd/project.yaml")
    apps = sha256(join(",", [
      for manifest in sort(fileset("${path.root}/../gitops/argocd", "app-*.yaml")) :
      filesha256("${path.root}/../gitops/argocd/${manifest}")
    ]))
  }

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    environment = {
      KUBE_SERVER = data.aws_eks_cluster.this.endpoint
      KUBE_CA     = data.aws_eks_cluster.this.certificate_authority[0].data
      KUBE_TOKEN  = data.aws_eks_cluster_auth.this.token
    }
    command = <<-EOT
      set -eu
      ca_file="$(mktemp)"
      trap 'rm -f "$ca_file"' EXIT
      printf '%s' "$KUBE_CA" | base64 -d > "$ca_file"

      kubectl_base="kubectl --server=$KUBE_SERVER --certificate-authority=$ca_file --token=$KUBE_TOKEN"

      until $kubectl_base get crd applications.argoproj.io >/dev/null 2>&1 && \
            $kubectl_base get crd appprojects.argoproj.io >/dev/null 2>&1; do
        echo "Waiting for ArgoCD CRDs..."
        sleep 10
      done

      $kubectl_base apply -f "${path.root}/../gitops/argocd/project.yaml"
      $kubectl_base apply -f "${path.root}/../gitops/argocd/"
    EOT
  }

  depends_on = [module.argocd]
}
