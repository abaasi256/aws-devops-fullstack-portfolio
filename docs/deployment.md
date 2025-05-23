# Deployment Guide

This guide provides step-by-step instructions for deploying the complete DevOps Portfolio Project on AWS.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Infrastructure Deployment](#infrastructure-deployment)
- [Database Setup](#database-setup)
- [Application Deployment](#application-deployment)
- [CI/CD Pipeline Setup](#cicd-pipeline-setup)
- [Monitoring Setup](#monitoring-setup)
- [DNS and SSL Configuration](#dns-and-ssl-configuration)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before starting the deployment, ensure you have:

1. **AWS Account** with appropriate permissions
2. **Terraform** (v1.0 or later) installed
3. **AWS CLI** installed and configured with access credentials
4. **Node.js** (v16 or later) and **npm** installed
5. **Git** installed
6. **Domain Name** (optional, for SSL/TLS)

### AWS User Setup

If you're setting up a new IAM user for this project, ensure it has the following permissions:

- AmazonEC2FullAccess
- AmazonRDSFullAccess
- AmazonS3FullAccess
- AmazonVPCFullAccess
- AmazonRoute53FullAccess
- IAMFullAccess
- AmazonSSMFullAccess
- CloudWatchFullAccess
- AWSCodeBuildAdminAccess
- AWSCodeDeployFullAccess
- AWSCodePipelineFullAccess

## Setting Up an EC2 Key Pair for Deployment

Before deploying the infrastructure, you need to create an EC2 key pair that will be used for SSH access to your instances and automated deployments via CI/CD pipelines.

### Creating a Key Pair via AWS Console

1. **Navigate to EC2 Console**:
   - Open the AWS Console and go to the EC2 service
   - In the left navigation pane, click on "Key Pairs" under "Network & Security"

2. **Create Key Pair**:
   - Click "Create key pair"
   - Name: `devops-portfolio-key` (or your preferred name)
   - Key pair type: RSA
   - Private key file format: `.pem` (for OpenSSH)
   - Click "Create key pair"

3. **Download and Secure the Key**:
   - The private key file will download automatically
   - Move it to a secure location: `~/.ssh/devops-portfolio-key.pem`
   - Set proper permissions: `chmod 400 ~/.ssh/devops-portfolio-key.pem`

### Creating a Key Pair via AWS CLI

```bash
# Create the key pair and save the private key
mkdir -p ~/.ssh

aws ec2 create-key-pair \
  --key-name devops-portfolio-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/devops-portfolio-key.pem

chmod 400 ~/.ssh/devops-portfolio-key.pem
```

### Adding the Private Key to GitHub Actions Secrets

For automated deployments via GitHub Actions:

1. **Encode the Private Key**:
   ```bash
   cat ~/.ssh/devops-portfolio-key.pem | base64
   ```

2. **Add to GitHub Secrets**:
   - Go to your GitHub repository
   - Navigate to Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `EC2_PRIVATE_KEY`
   - Value: Paste the base64-encoded private key
   - Click "Add secret"

### Adding the Private Key to AWS Systems Manager (Alternative)

For enhanced security, you can store the private key in AWS Systems Manager Parameter Store:

```bash
# Store the private key in Parameter Store
aws ssm put-parameter \
    --name "/devops-portfolio/ssh/private-key" \
    --value "$(cat ~/.ssh/devops-portfolio-key.pem)" \
    --type "SecureString" \
    --description "Private key for EC2 SSH access"
```

### How the Key is Used in CI/CD

The EC2 key pair serves several purposes in the deployment pipeline:

1. **Infrastructure Provisioning**: Terraform assigns the key pair to all EC2 instances
2. **SSH Access**: Allows secure shell access to instances for debugging and maintenance
3. **Automated Deployment**: CI/CD pipelines use the key for:
   - Copying deployment artifacts to instances
   - Running deployment scripts
   - Performing health checks
   - Rolling back deployments if needed

### Security Best Practices

- **Never commit private keys to version control**
- **Use different key pairs for different environments** (dev, staging, prod)
- **Rotate key pairs regularly** (every 90 days recommended)
- **Limit SSH access** by configuring security groups appropriately
- **Consider using AWS Systems Manager Session Manager** for enhanced security

### Testing SSH Access

After deployment, test SSH access to your instances:

```bash
# Get instance IP from Terraform output or AWS Console
ssh -i ~/.ssh/devops-portfolio-key.pem ec2-user@<instance-ip>
```

### Troubleshooting Key Pair Issues

Common issues and solutions:

- **Permission denied (publickey)**: Check file permissions (`chmod 400`)
- **Key not found**: Verify the key name in `terraform.tfvars`
- **Connection refused**: Check security group SSH rules (port 22)
- **Host key verification failed**: Run `ssh-keyscan <instance-ip> >> ~/.ssh/known_hosts`

## Infrastructure Deployment

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/devops-portfolio-project.git
cd devops-portfolio-project
```

### 2. Configure Terraform Variables

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific configuration values:

```hcl
# Project Configuration
project_name = "devops-portfolio"
environment  = "prod"
aws_region   = "us-east-1"

# EC2 Configuration
ec2_key_name = "devops-portfolio-key"  # Name of your EC2 key pair

# Database Configuration
db_master_username = "admin"
db_master_password = "YourSecurePasswordHere"

# Domain Configuration (optional)
domain_name      = "yourdomain.com"
route53_zone_id  = "Z1234567890ABC"
```

### 3. Initialize Terraform

```bash
terraform init
```

This will download the required providers and initialize the Terraform modules.

### 4. Create Execution Plan

```bash
terraform plan
```

Review the execution plan to ensure it aligns with your expectations.

### 5. Apply Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm the creation of resources.

This process will take approximately 10-15 minutes to complete.

### 6. Note Output Values

After the deployment completes, Terraform will display output values. Make note of these values as they will be needed for subsequent steps:

- VPC ID
- Public and Private Subnet IDs
- EC2 Security Group ID
- RDS Security Group ID
- ALB DNS Name
- DB Endpoint
- CloudWatch Dashboard URL

## Database Setup

The database structure is automatically created when the backend starts for the first time. However, you can verify the database connection:

```bash
mysql -h <db_endpoint> -u <username> -p
```

## Application Deployment

If you're using the CI/CD pipeline (recommended), the application will be deployed automatically when you push to the main branch.

For manual deployment:

### 1. Build Frontend

```bash
cd frontend
npm install
npm run build
```

### 2. Prepare Backend

```bash
cd ../backend
npm install
```

### 3. Create Deployment Package

```bash
cd ..
mkdir -p deployment-package
cp -r backend/* deployment-package/
mkdir -p deployment-package/frontend/build
cp -r frontend/build/* deployment-package/frontend/build/
cd deployment-package
zip -r ../deployment.zip *
```

### 4. Deploy to EC2

Upload the deployment.zip file to an S3 bucket:

```bash
aws s3 cp deployment.zip s3://<your-deployment-bucket>/deployment.zip
```

Then, SSH into the EC2 instance and deploy:

```bash
ssh -i your-key.pem ec2-user@<ec2-instance-ip>
mkdir -p /opt/app
cd /opt/app
aws s3 cp s3://<your-deployment-bucket>/deployment.zip .
unzip deployment.zip
npm install --production
pm2 start server.js
```

## CI/CD Pipeline Setup

### AWS CodePipeline Setup

```bash
cd ci/aws
./setup-pipeline.sh
```

Follow the prompts to configure the pipeline:

- GitHub repository owner and name
- GitHub OAuth token
- AWS region
- CloudFormation stack name

### GitHub Actions Setup

If using GitHub Actions, you'll need to add the following secrets to your GitHub repository:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `S3_BUCKET`

The GitHub Actions workflow will be triggered automatically on push to the main branch.

## Monitoring Setup

Set up CloudWatch monitoring:

```bash
cd monitoring
./setup-monitoring.sh
```

Follow the prompts to configure monitoring:

- Auto Scaling Group name
- DB Cluster Identifier
- Load Balancer ARN
- Email for alarm notifications

## DNS and SSL Configuration

### 1. Update Route 53 DNS

Create an A record for your domain that points to the ALB DNS name:

1. Go to the AWS Route 53 console
2. Select your hosted zone
3. Create a new record set:
   - Name: your domain name
   - Type: A
   - Alias: Yes
   - Alias Target: Your ALB DNS name

### 2. Validate ACM Certificate

If you created a new ACM certificate, you may need to validate it:

1. Go to the AWS ACM console
2. Select the certificate
3. Follow the validation instructions (usually adding a CNAME record to your DNS)

## Verification

### 1. Check Infrastructure

Verify that all resources have been created:

```bash
terraform state list
```

### 2. Check Application

Open your domain in a web browser (or the ALB DNS name if not using a custom domain).

Try logging in with the default credentials:
- Username: admin
- Password: password123

### 3. Check Monitoring

Access the CloudWatch dashboard using the URL from Terraform outputs:

```
https://<region>.console.aws.amazon.com/cloudwatch/home?region=<region>#dashboards:name=DevOpsPortfolio-Dashboard
```

## Troubleshooting

### Common Issues

#### Terraform Apply Fails

- Check AWS credentials
- Verify IAM permissions
- Check for resource name conflicts
- Look for error messages in the Terraform output

#### Application Not Loading

- Check if EC2 instances are running
- Verify security group rules
- Check application logs: `/opt/app/logs/`
- Verify ALB health checks

#### Database Connection Issues

- Check security group rules
- Verify database credentials
- Check database accessibility from EC2 instances

### Viewing Logs

**EC2 Application Logs**:
```bash
ssh -i your-key.pem ec2-user@<ec2-instance-ip>
cd /opt/app/logs
cat all.log
```

**CloudWatch Logs**:
Access logs in the CloudWatch console under Log Groups:
- `/aws/ec2/devops-portfolio/application`
- `/aws/ec2/devops-portfolio/error`
- `/aws/ec2/devops-portfolio/nginx-access`
- `/aws/ec2/devops-portfolio/nginx-error`

### Getting Help

If you encounter issues not covered here, check:
- AWS Service Health Dashboard
- Terraform documentation
- GitHub Issues for this project
