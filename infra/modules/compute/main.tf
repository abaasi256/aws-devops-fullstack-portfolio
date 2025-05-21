# EC2 Instances, Auto Scaling Group, Application Load Balancer

# Create Target Group for ALB
resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# Create ALB
resource "aws_lb" "app" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Create HTTP Listener (Redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Create Launch Template for EC2 instances
resource "aws_launch_template" "app" {
  name                   = "${var.project_name}-launch-template"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.ec2_security_group_id]
  
  iam_instance_profile {
    name = var.ec2_instance_profile_name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  # User data script to install dependencies and set up the application
  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Update and install dependencies
    yum update -y
    yum install -y amazon-linux-extras
    
    # Install Node.js
    curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
    yum install -y nodejs
    
    # Install Git
    yum install -y git
    
    # Install CloudWatch agent
    yum install -y amazon-cloudwatch-agent
    
    # Set up application directory
    mkdir -p /opt/app
    cd /opt/app
    
    # Clone the application repository
    # git clone https://github.com/your-repo/your-app.git .
    
    # Create health check endpoint
    mkdir -p /opt/app/public
    echo "OK" > /opt/app/public/health
    
    # Set up Nginx
    amazon-linux-extras install nginx1 -y
    
    # Configure Nginx
    cat > /etc/nginx/conf.d/app.conf << 'EOL'
    server {
        listen 80;
        server_name _;
        
        location /health {
            root /opt/app/public;
            try_files $uri =200;
        }
        
        location /api {
            proxy_pass http://localhost:3000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }
        
        location / {
            root /opt/app/frontend/build;
            index index.html;
            try_files $uri $uri/ /index.html;
        }
    }
    EOL
    
    # Start Nginx
    systemctl enable nginx
    systemctl start nginx
    
    # Set up application as a service
    cat > /etc/systemd/system/app.service << 'EOL'
    [Unit]
    Description=Node.js Application
    After=network.target
    
    [Service]
    Type=simple
    User=ec2-user
    WorkingDirectory=/opt/app/backend
    ExecStart=/usr/bin/node /opt/app/backend/server.js
    Restart=on-failure
    
    [Install]
    WantedBy=multi-user.target
    EOL
    
    # Start application
    systemctl enable app
    systemctl start app
  EOF
  )

  tags = {
    Name = "${var.project_name}-launch-template"
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-asg"
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = var.private_subnet_ids
  
  target_group_arns = [aws_lb_target_group.app.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.project_name}-instance"
    propagate_at_launch = true
  }
}

# Create CPU Utilization Scaling Policy
resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "${var.project_name}-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

# Route 53 Record for the ALB
resource "aws_route53_record" "app" {
  count   = var.create_dns_record ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}
