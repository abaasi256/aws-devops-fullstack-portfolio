output "app_log_group_name" {
  description = "Name of the CloudWatch Log Group for application logs"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "nginx_access_log_group_name" {
  description = "Name of the CloudWatch Log Group for Nginx access logs"
  value       = aws_cloudwatch_log_group.nginx_access_logs.name
}

output "nginx_error_log_group_name" {
  description = "Name of the CloudWatch Log Group for Nginx error logs"
  value       = aws_cloudwatch_log_group.nginx_error_logs.name
}

output "dashboard_name" {
  description = "Name of the CloudWatch Dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "alarms_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.arn
}
