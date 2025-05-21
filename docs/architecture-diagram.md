# Architecture Diagram

This is a simple ASCII architecture diagram. In a real implementation, you would replace this with a proper diagram created with a tool like draw.io, Lucidchart, or AWS Architecture Diagram tool.

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
│                                                  │                           │
│                                                  │                           │
│                                 ┌────────────────▼───────────────────┐      │
│                                 │                                     │      │
│                                 │  ACM Certificate                    │      │
│                                 │  (HTTPS)                            │      │
│                                 │                                     │      │
│                                 └────────────────┬───────────────────┘      │
│                                                  │                           │
│  AWS Region (us-east-1)                         │                           │
│                                                  ▼                           │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  VPC (10.0.0.0/16)                                                   │    │
│  │                                                                      │    │
│  │  ┌────────────────┐     ┌────────────────┐     ┌────────────────┐   │    │
│  │  │                │     │                │     │                │   │    │
│  │  │  Public        │     │  Public        │     │  Public        │   │    │
│  │  │  Subnet 1      │     │  Subnet 2      │     │  Subnet 3      │   │    │
│  │  │  10.0.1.0/24   │     │  10.0.2.0/24   │     │  10.0.3.0/24   │   │    │
│  │  │  (us-east-1a)  │     │  (us-east-1b)  │     │  (us-east-1c)  │   │    │
│  │  │                │     │                │     │                │   │    │
│  │  └────────┬───────┘     └────────┬───────┘     └────────┬───────┘   │    │
│  │           │                      │                      │           │    │
│  │           ▼                      ▼                      ▼           │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │                                                             │   │    │
│  │  │            Application Load Balancer (ALB)                  │   │    │
│  │  │                                                             │   │    │
│  │  └─────────────────────────────┬───────────────────────────────┘   │    │
│  │                                │                                    │    │
│  │                                ▼                                    │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │  Auto Scaling Group                                         │   │    │
│  │  │                                                             │   │    │
│  │  │  ┌─────────────┐         ┌─────────────┐                    │   │    │
│  │  │  │             │         │             │                    │   │    │
│  │  │  │  EC2        │         │  EC2        │                    │   │    │
│  │  │  │  Instance   │         │  Instance   │                    │   │    │
│  │  │  │  (Frontend/ │         │  (Frontend/ │                    │   │    │
│  │  │  │  Backend)   │         │  Backend)   │                    │   │    │
│  │  │  │             │         │             │                    │   │    │
│  │  │  └─────────────┘         └─────────────┘                    │   │    │
│  │  │                                                             │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                      │    │
│  │  ┌────────────────┐     ┌────────────────┐     ┌────────────────┐   │    │
│  │  │                │     │                │     │                │   │    │
│  │  │  Private       │     │  Private       │     │  Private       │   │    │
│  │  │  Subnet 1      │     │  Subnet 2      │     │  Subnet 3      │   │    │
│  │  │  10.0.4.0/24   │     │  10.0.5.0/24   │     │  10.0.6.0/24   │   │    │
│  │  │  (us-east-1a)  │     │  (us-east-1b)  │     │  (us-east-1c)  │   │    │
│  │  │                │     │                │     │                │   │    │
│  │  └────────┬───────┘     └────────┬───────┘     └────────┬───────┘   │    │
│  │           │                      │                      │           │    │
│  │           └──────────────────────┼──────────────────────┘           │    │
│  │                                  │                                   │    │
│  │                                  ▼                                   │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │                                                             │   │    │
│  │  │            Aurora MySQL Cluster                             │   │    │
│  │  │            (Primary + Read Replica)                         │   │    │
│  │  │                                                             │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                      │    │
│  └──────────────────────────────────────────────────────────────────────┘    │
│                                                                               │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                                                                     │    │
│  │  CI/CD Pipeline (CodePipeline + CodeBuild or GitHub Actions)        │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                                                                     │    │
│  │  CloudWatch (Logs, Metrics, Alarms)                                │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

## Overview

The architecture follows a 3-tier model deployed on AWS:

1. **Presentation Tier**: React.js frontend running on EC2 instances
2. **Application Tier**: Node.js/Express backend running on the same EC2 instances
3. **Data Tier**: Aurora MySQL on AWS RDS

## Key Components

### Networking

- **VPC**: Isolated network environment (10.0.0.0/16)
- **Public Subnets**: For ALB (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
- **Private Subnets**: For EC2 and RDS (10.0.4.0/24, 10.0.5.0/24, 10.0.6.0/24)
- **Internet Gateway**: For public internet access
- **NAT Gateway**: For private subnet outbound internet access

### Compute

- **EC2 Instances**: Running both frontend and backend applications
- **Auto Scaling Group**: Maintains desired capacity of EC2 instances
- **Launch Template**: Defines EC2 instance configuration

### Database

- **Aurora MySQL**: Managed MySQL-compatible database
- **Multi-AZ Deployment**: For high availability
- **Read Replicas**: For improved performance

### Routing and Security

- **Application Load Balancer**: Distributes traffic across EC2 instances
- **Route 53**: DNS management
- **ACM Certificate**: For SSL/TLS encryption
- **Security Groups**: Control traffic to resources

### CI/CD

- **CodePipeline** or **GitHub Actions**: Orchestrates the CI/CD workflow
- **CodeBuild**: Builds and tests the application
- **CodeDeploy**: Deploys the application to EC2 instances
- **S3 Bucket**: Stores deployment artifacts

### Monitoring

- **CloudWatch Metrics**: System and application metrics
- **CloudWatch Logs**: Application, access, and error logs
- **CloudWatch Alarms**: Notifications for threshold breaches
- **CloudWatch Dashboard**: Visualization of all key metrics
