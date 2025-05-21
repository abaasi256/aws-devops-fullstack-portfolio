# AWS Architecture for DevOps Portfolio Project

## Overview

This document outlines the AWS architecture for a production-ready full-stack web application deployment. The architecture follows AWS best practices for security, scalability, and maintainability.

## Architecture Components

### Infrastructure Diagram

```
                                                ┌─────────────────────┐
                                                │                     │
                                                │  Route 53           │
                                                │  (DNS Management)   │
                                                │                     │
                                                └─────────┬───────────┘
                                                          │
                                                          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                         │                    │
│                                                         │                    │
│                                    ┌───────────────────▼──────────────────┐ │
│                                    │                                       │ │
│                                    │  ACM Certificate                      │ │
│                                    │  (HTTPS)                              │ │
│                                    │                                       │ │
│                                    └───────────────────┬──────────────────┘ │
│                                                        │                    │
│  AWS Region (us-east-1)                                │                    │
│                                                        ▼                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  VPC (10.0.0.0/16)                                                   │   │
│  │                                                                      │   │
│  │  ┌────────────────┐     ┌────────────────┐     ┌────────────────┐   │   │
│  │  │                │     │                │     │                │   │   │
│  │  │  Public        │     │  Public        │     │  Public        │   │   │
│  │  │  Subnet 1      │     │  Subnet 2      │     │  Subnet 3      │   │   │
│  │  │  10.0.1.0/24   │     │  10.0.2.0/24   │     │  10.0.3.0/24   │   │   │
│  │  │  (us-east-1a)  │     │  (us-east-1b)  │     │  (us-east-1c)  │   │   │
│  │  │                │     │                │     │                │   │   │
│  │  └────────┬───────┘     └────────┬───────┘     └────────┬───────┘   │   │
│  │           │                      │                      │           │   │
│  │           ▼                      ▼                      ▼           │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │                                                             │   │   │
│  │  │            Application Load Balancer (ALB)                  │   │   │
│  │  │                                                             │   │   │
│  │  └─────────────────────────────┬───────────────────────────────┘   │   │
│  │                                │                                    │   │
│  │                                ▼                                    │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │  Auto Scaling Group                                         │   │   │
│  │  │                                                             │   │   │
│  │  │  ┌─────────────┐         ┌─────────────┐                    │   │   │
│  │  │  │             │         │             │                    │   │   │
│  │  │  │  EC2        │         │  EC2        │                    │   │   │
│  │  │  │  Instance   │         │  Instance   │                    │   │   │
│  │  │  │  (Frontend/ │         │  (Frontend/ │                    │   │   │
│  │  │  │  Backend)   │         │  Backend)   │                    │   │   │
│  │  │  │             │         │             │                    │   │   │
│  │  │  └─────────────┘         └─────────────┘                    │   │   │
│  │  │                                                             │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  │                                                                      │   │
│  │  ┌────────────────┐     ┌────────────────┐     ┌────────────────┐   │   │
│  │  │                │     │                │     │                │   │   │
│  │  │  Private       │     │  Private       │     │  Private       │   │   │
│  │  │  Subnet 1      │     │  Subnet 2      │     │  Subnet 3      │   │   │
│  │  │  10.0.4.0/24   │     │  10.0.5.0/24   │     │  10.0.6.0/24   │   │   │
│  │  │  (us-east-1a)  │     │  (us-east-1b)  │     │  (us-east-1c)  │   │   │
│  │  │                │     │                │     │                │   │   │
│  │  └────────┬───────┘     └────────┬───────┘     └────────┬───────┘   │   │
│  │           │                      │                      │           │   │
│  │           └──────────────────────┼──────────────────────┘           │   │
│  │                                  │                                   │   │
│  │                                  ▼                                   │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │                                                             │   │   │
│  │  │            Aurora MySQL Cluster                             │   │   │
│  │  │            (Primary + Read Replica)                         │   │   │
│  │  │                                                             │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │  CI/CD Pipeline (CodePipeline + CodeBuild or GitHub Actions)        │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │  CloudWatch (Logs, Metrics, Alarms)                                │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Networking (VPC)

- **VPC**: A dedicated VPC with CIDR block 10.0.0.0/16
- **Subnets**:
  - 3 Public Subnets (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24) in different AZs
  - 3 Private Subnets (10.0.4.0/24, 10.0.5.0/24, 10.0.6.0/24) in different AZs
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: For private subnet outbound internet access
- **Route Tables**: Separate route tables for public and private subnets

### 2. Security

- **Security Groups**:
  - ALB Security Group: Allows HTTP/HTTPS from the internet
  - EC2 Security Group: Allows traffic only from ALB
  - RDS Security Group: Allows MySQL traffic only from EC2 instances
- **Network ACLs**: Default NACLs with custom rules for additional security
- **IAM Roles**: Least privilege access for EC2, RDS, and other resources

### 3. Compute (EC2)

- **Instance Type**: t3.medium (2 vCPU, 4 GB RAM)
- **AMI**: Amazon Linux 2023
- **Auto Scaling Group**: 
  - Min: 2, Max: 4 instances
  - Scale based on CPU utilization (>70%)
- **User Data**: Bootstrap script to install dependencies and configure the application

### 4. Database (Aurora MySQL)

- **Instance Type**: db.t3.medium
- **Multi-AZ**: Enabled for high availability
- **Storage**: 20 GB allocated with autoscaling enabled
- **Backup**: Daily automated backups with 7-day retention
- **Parameters**: Optimized for the application workload

### 5. Load Balancing (ALB)

- **Application Load Balancer**:
  - Deployed across multiple AZs
  - HTTP to HTTPS redirection
  - Path-based routing for frontend and backend
- **Target Groups**:
  - Health check path: /health
  - Interval: 30 seconds
  - Healthy threshold: 3
  - Unhealthy threshold: 2

### 6. DNS & SSL (Route 53 & ACM)

- **Route 53**:
  - Hosted zone for domain management
  - A record pointing to ALB
  - Health checks for failover
- **ACM**:
  - SSL/TLS certificate for HTTPS
  - Auto-renewal enabled

### 7. CI/CD Pipeline

- **Options**:
  1. **AWS Native**: CodePipeline + CodeBuild
  2. **GitHub Actions**: Workflow with AWS deployment
- **Stages**:
  - Source (GitHub repository)
  - Build (Install dependencies, run tests)
  - Deploy (Update EC2 instances)

### 8. Monitoring & Logging

- **CloudWatch**:
  - Metrics for EC2, ALB, RDS
  - Custom metrics for application performance
  - Alarms for critical thresholds
- **Logs**:
  - Application logs
  - Access logs
  - Error logs
  - Database logs
- **Dashboards**: Custom dashboards for key metrics visualization

## Infrastructure as Code (Terraform)

All infrastructure will be defined using Terraform modules organized as follows:

```
infra/
├── main.tf           # Main Terraform configuration
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── terraform.tfvars  # Variable values
├── modules/
│   ├── networking/   # VPC, subnets, etc.
│   ├── security/     # Security groups, IAM roles
│   ├── compute/      # EC2, ASG, ALB
│   ├── database/     # Aurora MySQL
│   └── monitoring/   # CloudWatch
└── environments/
    ├── dev/          # Development environment
    └── prod/         # Production environment
```

## Application Architecture

### Frontend (React)

- React SPA deployed to EC2 instances
- Key features:
  - User authentication
  - Dashboard
  - Responsive design

### Backend (Node.js/Express)

- RESTful API deployed to the same EC2 instances
- Key endpoints:
  - Authentication (login, registration)
  - User management
  - Health check

### Database Schema

- Core tables:
  - Users
  - Sessions
  - Application data

## Deployment Workflow

1. Developer commits code to GitHub repository
2. CI/CD pipeline is triggered
3. Tests run automatically
4. If tests pass, application is built and deployed to EC2 instances
5. Health checks verify successful deployment
6. CloudWatch monitors application performance

## Cost Optimization

- EC2 Reserved Instances for predictable workloads
- Auto Scaling for variable workloads
- RDS Aurora Serverless for development environments
- CloudWatch detailed monitoring for resource optimization

## Next Steps for Implementation

1. Set up Terraform configurations for all resources
2. Configure CI/CD pipeline
3. Develop and deploy application code
4. Set up monitoring and alerting
5. Document deployment and management procedures
