# CloudWatch Logs and Metrics

# CloudWatch Log Group for Application Logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/ec2/${var.project_name}-app"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-app-logs"
  }
}

# CloudWatch Log Group for Nginx Access Logs
resource "aws_cloudwatch_log_group" "nginx_access_logs" {
  name              = "/aws/ec2/${var.project_name}-nginx-access"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-nginx-access-logs"
  }
}

# CloudWatch Log Group for Nginx Error Logs
resource "aws_cloudwatch_log_group" "nginx_error_logs" {
  name              = "/aws/ec2/${var.project_name}-nginx-error"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-nginx-error-logs"
  }
}

# CloudWatch Metric Alarm for High CPU Utilization
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric checks if the CPU utilization is greater than 80%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }
}

# CloudWatch Metric Alarm for Low Free Memory
resource "aws_cloudwatch_metric_alarm" "low_memory" {
  alarm_name          = "${var.project_name}-low-memory-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryAvailable"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 1000000000  # 1 GB in bytes
  alarm_description   = "This metric checks if the available memory is less than 1 GB"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }
}

# CloudWatch Metric Alarm for High Database CPU
resource "aws_cloudwatch_metric_alarm" "high_db_cpu" {
  alarm_name          = "${var.project_name}-high-db-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric checks if the database CPU utilization is greater than 80%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBClusterIdentifier = var.db_cluster_identifier
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.autoscaling_group_name]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["CWAgent", "MemoryAvailable", "AutoScalingGroupName", var.autoscaling_group_name]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 Memory Available"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBClusterIdentifier", var.db_cluster_identifier]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "FreeableMemory", "DBClusterIdentifier", var.db_cluster_identifier]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS Freeable Memory"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "ALB Request Count"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ALB Response Time"
        }
      }
    ]
  })
}

# SNS Topic for Alarms
resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-alarms-topic"
  
  tags = {
    Name = "${var.project_name}-alarms-topic"
  }
}

# Optional: SNS Topic Subscription for Email Notifications
resource "aws_sns_topic_subscription" "email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}
