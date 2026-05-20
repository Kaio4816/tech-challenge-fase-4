resource "aws_db_subnet_group" "db-subnet" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for PostgreSQL RDS instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-sg"
  }
}

locals {
  databases = {
    auth-service = {
      identifier = "auth-service"
    }
    flag-service = {
      identifier = "flag-service"
    }
    targeting-service = {
      identifier = "targeting-service"
    }
  }
}

resource "aws_db_instance" "postgres" {
  for_each = local.databases

  identifier            = each.value.identifier
  engine                = "postgres"
  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot = true
  publicly_accessible = false
  multi_az            = false
  deletion_protection = false

  tags = {
    Name    = each.value.identifier
    Service = each.key
  }
}

resource "aws_security_group_rule" "rds_all_from_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = [var.vpc_cidr]
  description       = "Allow ALL traffic from VPC"
}