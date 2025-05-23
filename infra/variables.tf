# Variables for the main module

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-portfolio"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Security Variables
variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH to EC2 instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Should be restricted in production
}

# Compute Variables
variable "ami_id" {
  description = "ID of the AMI to use for EC2 instances"
  type        = string
  default     = "ami-0e731c8a588258d0d"  # Amazon Linux 2023 AMI (us-east-1)
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t3.medium"
}

variable "ec2_key_name" {
  description = "Name of the EC2 key pair for SSH access (leave empty to disable SSH access)"
  type        = string
  default     = ""
}

variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 2
}

# Database Variables
variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "appdb"
}

variable "db_master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "db_master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "db_engine_version" {
  description = "Engine version for Aurora MySQL"
  type        = string
  default     = "8.0.mysql_aurora.3.03.1"
}

variable "db_instance_class" {
  description = "Instance class for Aurora MySQL instances"
  type        = string
  default     = "db.t3.medium"
}

variable "db_instance_count" {
  description = "Number of Aurora MySQL instances"
  type        = number
  default     = 2
}

# DNS and SSL Variables
variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "create_dns_record" {
  description = "Whether to create a DNS record for the ALB"
  type        = bool
  default     = true
}

variable "route53_zone_id" {
  description = "ID of the Route 53 hosted zone"
  type        = string
}

# Monitoring Variables
variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "alarm_email" {
  description = "Email address to send alarm notifications to"
  type        = string
  default     = ""
}
