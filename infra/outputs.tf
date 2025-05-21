# Outputs for the main module

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.compute.alb_dns_name
}

output "db_endpoint" {
  description = "Endpoint of the Aurora cluster"
  value       = module.database.cluster_endpoint
}

output "db_reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster"
  value       = module.database.reader_endpoint
}

output "db_name" {
  description = "Name of the database"
  value       = module.database.database_name
}

output "cloudwatch_dashboard_url" {
  description = "URL of the CloudWatch Dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${module.monitoring.dashboard_name}"
}

output "deployment_bucket" {
  description = "Name of the S3 bucket for deployment"
  value       = aws_s3_bucket.deployment.bucket
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = module.security.ec2_security_group_id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = module.security.rds_security_group_id
}

output "alarms_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = module.monitoring.alarms_topic_arn
}

output "application_url" {
  description = "URL of the application"
  value       = "https://${var.domain_name}"
}
