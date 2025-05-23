output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.app.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_lb.app.zone_id
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.app.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.app.id
}

output "bastion_public_ip" {
  description = "The public IP address of the bastion host"
  value       = var.create_bastion ? aws_eip.bastion[0].public_ip : null
}

output "bastion_instance_id" {
  description = "The instance ID of the bastion host"
  value       = var.create_bastion ? aws_instance.bastion[0].id : null
}
