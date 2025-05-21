variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH to EC2 instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Should be restricted in production
}

variable "deployment_bucket_name" {
  description = "Name of the S3 bucket used for code deployment"
  type        = string
  default     = "devops-portfolio-deployment-bucket"
}
