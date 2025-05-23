# Bastion Host for SSH Access to Private Instances

# Bastion Host for SSH Access to Private Instances

# Security Group for Bastion Host
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  # SSH from anywhere (should be restricted in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # TODO: Restrict to specific IPs in production
    description = "SSH from allowed CIDRs"
  }

  # Outbound to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Outbound to anywhere"
  }

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

# Update EC2 security group to allow SSH from bastion
resource "aws_security_group_rule" "ec2_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = var.ec2_security_group_id
  description              = "SSH from bastion host"
}

# Bastion Host Instance
resource "aws_instance" "bastion" {
  count                  = var.create_bastion ? 1 : 0
  ami                    = var.ami_id
  instance_type          = "t3.micro"  # Small instance for bastion
  key_name               = var.ec2_key_name != "" ? var.ec2_key_name : null
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = var.public_subnet_ids[0]  # Launch in first public subnet
  
  # Enable detailed monitoring
  monitoring = true
  
  # Associate public IP
  associate_public_ip_address = true

  # User data for bastion setup
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y awscli
    
    # Create a welcome message
    echo "Welcome to ${var.project_name} Bastion Host" > /etc/motd
    echo "Use this host to access private instances in the VPC" >> /etc/motd
  EOF
  )

  tags = {
    Name = "${var.project_name}-bastion"
    Type = "BastionHost"
  }
}

# Elastic IP for Bastion (optional but recommended)
resource "aws_eip" "bastion" {
  count    = var.create_bastion ? 1 : 0
  instance = aws_instance.bastion[0].id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-bastion-eip"
  }
}
