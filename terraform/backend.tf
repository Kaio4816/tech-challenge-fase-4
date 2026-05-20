# backend.tf
# Configuração do backend remoto para armazenar o state no S3

terraform {
  backend "s3" {
    bucket       = "iac-final-state-kaio"
    key          = "infra/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}