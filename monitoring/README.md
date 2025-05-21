# Monitoring Setup Guide

This document outlines the monitoring setup for the DevOps Portfolio Project. It explains how to set up CloudWatch monitoring for all components of the application.

## Table of Contents

1. [Overview](#overview)
2. [CloudWatch Agent](#cloudwatch-agent)
3. [CloudWatch Alarms](#cloudwatch-alarms)
4. [CloudWatch Dashboard](#cloudwatch-dashboard)
5. [Log Groups](#log-groups)
6. [Automated Setup](#automated-setup)

## Overview

The monitoring solution for this project uses Amazon CloudWatch to:

- Collect system and application metrics from EC2 instances
- Collect logs from the application, web server, and system
- Set up alarms for critical thresholds
- Create dashboards for visualizing system health and performance

## CloudWatch Agent

The CloudWatch Agent is installed on each EC2 instance to collect system metrics and logs. The agent configuration is defined in `cloudwatch-agent-config.json`.

### Metrics Collected

- **CPU**: Usage by core, system, user, idle, and IO wait
- **Memory**: Used percentage, available percentage, total, available, and used
- **Disk**: Used percentage, free space, used space, and total space
- **Disk I/O**: IO time, read bytes, write bytes, read time, and write time
- **Network**: TCP connections (established, time_wait, close_wait)
- **Swap**: Used percentage, free space, and used space

### Installation on EC2 Instances

The CloudWatch Agent is installed during instance launch via the EC2 user data script. To manually install and configure it:

1. Install the agent:
   ```bash
   sudo yum install -y amazon-cloudwatch-agent
   ```

2. Configure using the SSM Parameter Store configuration:
   ```bash
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
     -a fetch-config \
     -m ec2 \
     -s \
     -c ssm:AmazonCloudWatch-DevOpsPortfolio-Config
   ```

## CloudWatch Alarms

Alarms are configured to trigger notifications when metrics exceed predefined thresholds. The alarm configuration is defined in `cloudwatch-alarms.yml`.

### EC2 Alarms

- **High CPU**: Triggers when CPU utilization exceeds 80% for 5 minutes
- **Low Memory**: Triggers when available memory falls below 20% for 5 minutes
- **High Disk Usage**: Triggers when disk usage exceeds 80% for 5 minutes

### RDS Alarms

- **High CPU**: Triggers when DB CPU exceeds 80% for 5 minutes
- **Low Memory**: Triggers when DB free memory falls below 1GB for 5 minutes

### ALB Alarms

- **High Latency**: Triggers when response time exceeds 2 seconds for 5 minutes
- **5XX Errors**: Triggers when ALB 5XX errors exceed 10 in 5 minutes

### Notifications

Alarms send notifications to an SNS topic, which can be subscribed to via email, SMS, or other endpoints.

## CloudWatch Dashboard

A comprehensive dashboard is created to visualize all key metrics in one place. The dashboard configuration is defined in `cloudwatch-dashboard.yml`.

### Widgets

- EC2 metrics (CPU, Memory, Disk)
- RDS metrics (CPU, Memory, Connections)
- ALB metrics (Request Count, Response Time, HTTP Status Codes)
- Recent application errors from logs

### Accessing the Dashboard

The dashboard can be accessed at:
```
https://<region>.console.aws.amazon.com/cloudwatch/home?region=<region>#dashboards:name=DevOpsPortfolio-Dashboard
```

## Log Groups

The following log groups are created to collect logs from various sources:

- **/aws/ec2/devops-portfolio/application**: Application logs
- **/aws/ec2/devops-portfolio/error**: Application error logs
- **/aws/ec2/devops-portfolio/nginx-access**: Nginx access logs
- **/aws/ec2/devops-portfolio/nginx-error**: Nginx error logs
- **/aws/ec2/devops-portfolio/system**: System logs

## Automated Setup

To automate the setup of all monitoring components, run the `setup-monitoring.sh` script:

```bash
chmod +x setup-monitoring.sh
./setup-monitoring.sh
```

The script will:

1. Create the CloudWatch Agent configuration in SSM Parameter Store
2. Deploy the CloudWatch Alarms CloudFormation stack
3. Deploy the CloudWatch Dashboard CloudFormation stack
4. Provide commands to configure CloudWatch Agent on EC2 instances

### Prerequisites

- AWS CLI installed and configured
- AWS credentials with permissions to create CloudFormation stacks, SSM parameters, etc.
- Auto Scaling Group, RDS, and ALB already deployed

### Required Information

You'll need to provide the following information when running the script:

- AWS region
- Auto Scaling Group name
- DB Cluster Identifier
- Load Balancer ARN
- Email address for alarm notifications
