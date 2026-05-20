# Projeto Terraform - Infraestrutura da Pós

Este projeto provisiona na AWS:

- VPC
- Subnets públicas e privadas
- Internet Gateway
- NAT Gateway
- Route Tables
- Cluster EKS
- Node Group do EKS
- 3 instâncias RDS PostgreSQL
- 1 ElastiCache Redis
- 1 tabela DynamoDB chamada ToggleMasterAnalytics
- 1 fila SQS
- 5 repositórios ECR

## Estrutura

O projeto foi organizado em módulos para facilitar manutenção, reutilização e clareza da arquitetura.

## Pré-requisitos

- Terraform >= 1.5
- AWS CLI autenticada na conta
- Permissões para criar recursos IAM, EKS, VPC, RDS, ElastiCache, DynamoDB, SQS e ECR

## Execução

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply -auto-approve