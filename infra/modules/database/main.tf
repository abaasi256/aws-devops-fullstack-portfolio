# Aurora MySQL Cluster

# Create DB Subnet Group
resource "aws_db_subnet_group" "aurora" {
  name        = "${var.project_name}-db-subnet-group"
  description = "DB subnet group for Aurora"
  subnet_ids  = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# Create Aurora MySQL Cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier     = "${var.project_name}-aurora-cluster"
  engine                 = "aurora-mysql"
  engine_version         = var.engine_version
  availability_zones     = var.availability_zones
  database_name          = var.database_name
  master_username        = var.master_username
  master_password        = var.master_password
  backup_retention_period = 7
  preferred_backup_window = "02:00-03:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [var.rds_security_group_id]
  storage_encrypted      = true

  tags = {
    Name = "${var.project_name}-aurora-cluster"
  }
}

# Create Aurora MySQL Instances
resource "aws_rds_cluster_instance" "aurora_instances" {
  count                = var.db_instance_count
  identifier           = "${var.project_name}-aurora-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.aurora.id
  instance_class       = var.db_instance_class
  engine               = "aurora-mysql"
  engine_version       = var.engine_version
  db_subnet_group_name = aws_db_subnet_group.aurora.name
  publicly_accessible  = false

  tags = {
    Name = "${var.project_name}-aurora-instance-${count.index}"
  }
}

# Create RDS Event Subscription for Notifications
resource "aws_db_event_subscription" "aurora_events" {
  name      = "${var.project_name}-aurora-events"
  sns_topic_arn = aws_sns_topic.db_events.arn
  source_type = "db-cluster"
  source_ids  = [aws_rds_cluster.aurora.id]
  
  event_categories = [
    "failover",
    "failure",
    "maintenance",
    "notification"
  ]

  tags = {
    Name = "${var.project_name}-aurora-events"
  }
}

# Create SNS Topic for RDS Events
resource "aws_sns_topic" "db_events" {
  name = "${var.project_name}-aurora-events-topic"
  
  tags = {
    Name = "${var.project_name}-aurora-events-topic"
  }
}
