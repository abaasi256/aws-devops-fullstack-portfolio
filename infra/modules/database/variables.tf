variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "ID of the RDS security group"
  type        = string
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "appdb"
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "engine_version" {
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
