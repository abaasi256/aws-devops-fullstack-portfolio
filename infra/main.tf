# Main Terraform configuration file

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Create ACM Certificate for HTTPS
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-certificate"
  }
}

# Create S3 Bucket for Deployment
resource "aws_s3_bucket" "deployment" {
  bucket = "${var.project_name}-deployment-${var.environment}"

  tags = {
    Name = "${var.project_name}-deployment-bucket"
  }
}

# Configure S3 Bucket for Versioning
resource "aws_s3_bucket_versioning" "deployment" {
  bucket = aws_s3_bucket.deployment.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure S3 Bucket for Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "deployment" {
  bucket = aws_s3_bucket.deployment.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones  = var.availability_zones
}

# Security Module
module "security" {
  source = "./modules/security"

  project_name          = var.project_name
  vpc_id                = module.networking.vpc_id
  ssh_allowed_cidrs     = var.ssh_allowed_cidrs
  deployment_bucket_name = aws_s3_bucket.deployment.id
}

# Database Module
module "database" {
  source = "./modules/database"

  project_name        = var.project_name
  private_subnet_ids  = module.networking.private_subnet_ids
  availability_zones  = var.availability_zones
  rds_security_group_id = module.security.rds_security_group_id
  database_name       = var.database_name
  master_username     = var.db_master_username
  master_password     = var.db_master_password
  engine_version      = var.db_engine_version
  db_instance_class   = var.db_instance_class
  db_instance_count   = var.db_instance_count
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  project_name           = var.project_name
  vpc_id                 = module.networking.vpc_id
  public_subnet_ids      = module.networking.public_subnet_ids
  private_subnet_ids     = module.networking.private_subnet_ids
  alb_security_group_id  = module.security.alb_security_group_id
  ec2_security_group_id  = module.security.ec2_security_group_id
  ec2_instance_profile_name = module.security.ec2_instance_profile_name
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  asg_min_size           = var.asg_min_size
  asg_max_size           = var.asg_max_size
  asg_desired_capacity   = var.asg_desired_capacity
  acm_certificate_arn    = aws_acm_certificate.cert.arn
  create_dns_record      = var.create_dns_record
  route53_zone_id        = var.route53_zone_id
  domain_name            = var.domain_name
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  project_name         = var.project_name
  aws_region           = var.aws_region
  log_retention_days   = var.log_retention_days
  autoscaling_group_name = module.compute.autoscaling_group_name
  db_cluster_identifier = module.database.cluster_identifier
  alb_arn_suffix       = split("/", module.compute.alb_arn)[1]
  alarm_email          = var.alarm_email
}

# Store Database Connection Information in SSM Parameter Store
resource "aws_ssm_parameter" "db_endpoint" {
  name        = "/${var.project_name}/${var.environment}/db_endpoint"
  description = "Database endpoint for ${var.project_name} application"
  type        = "String"
  value       = module.database.cluster_endpoint
}

resource "aws_ssm_parameter" "db_name" {
  name        = "/${var.project_name}/${var.environment}/db_name"
  description = "Database name for ${var.project_name} application"
  type        = "String"
  value       = module.database.database_name
}

resource "aws_ssm_parameter" "db_username" {
  name        = "/${var.project_name}/${var.environment}/db_username"
  description = "Database username for ${var.project_name} application"
  type        = "String"
  value       = module.database.master_username
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.project_name}/${var.environment}/db_password"
  description = "Database password for ${var.project_name} application"
  type        = "SecureString"
  value       = var.db_master_password
}
