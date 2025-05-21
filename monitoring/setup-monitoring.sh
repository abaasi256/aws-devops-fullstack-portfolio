#!/bin/bash

# Configuration
STACK_NAME="devops-portfolio-monitoring"
AWS_REGION="us-east-1"
AUTO_SCALING_GROUP_NAME=""
DB_CLUSTER_IDENTIFIER=""
LOAD_BALANCER_ARN=""
ALARM_EMAIL=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Get input parameters
echo -e "${YELLOW}Setting up CloudWatch Monitoring for DevOps Portfolio Project${NC}"
echo "----------------------------------------------------------------"

read -p "Enter AWS region [$AWS_REGION]: " input
AWS_REGION=${input:-$AWS_REGION}

read -p "Enter CloudFormation stack name [$STACK_NAME]: " input
STACK_NAME=${input:-$STACK_NAME}

read -p "Enter Auto Scaling Group name: " AUTO_SCALING_GROUP_NAME
read -p "Enter DB Cluster Identifier: " DB_CLUSTER_IDENTIFIER
read -p "Enter Load Balancer ARN: " LOAD_BALANCER_ARN
read -p "Enter email for alarm notifications: " ALARM_EMAIL

# Extract the Load Balancer name from the ARN
LOAD_BALANCER_NAME=$(echo $LOAD_BALANCER_ARN | cut -d'/' -f3)

echo -e "\n${YELLOW}Setting up CloudWatch Agent...${NC}"
# Install CloudWatch Agent via SSM Parameter Store
aws ssm put-parameter \
    --name "AmazonCloudWatch-DevOpsPortfolio-Config" \
    --type "String" \
    --value "$(cat cloudwatch-agent-config.json)" \
    --overwrite \
    --region $AWS_REGION

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to create CloudWatch Agent configuration parameter.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Creating CloudWatch Alarms...${NC}"
# Create CloudWatch Alarms
aws cloudformation deploy \
    --template-file cloudwatch-alarms.yml \
    --stack-name $STACK_NAME-alarms \
    --parameter-overrides \
        AutoScalingGroupName=$AUTO_SCALING_GROUP_NAME \
        DBClusterIdentifier=$DB_CLUSTER_IDENTIFIER \
        LoadBalancerFullName=$LOAD_BALANCER_NAME \
        AlarmEmail=$ALARM_EMAIL \
    --capabilities CAPABILITY_IAM \
    --region $AWS_REGION

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to create CloudWatch Alarms.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Creating CloudWatch Dashboard...${NC}"
# Create CloudWatch Dashboard
aws cloudformation deploy \
    --template-file cloudwatch-dashboard.yml \
    --stack-name $STACK_NAME-dashboard \
    --parameter-overrides \
        AutoScalingGroupName=$AUTO_SCALING_GROUP_NAME \
        DBClusterIdentifier=$DB_CLUSTER_IDENTIFIER \
        LoadBalancerFullName=$LOAD_BALANCER_NAME \
    --capabilities CAPABILITY_IAM \
    --region $AWS_REGION

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to create CloudWatch Dashboard.${NC}"
    exit 1
fi

echo -e "\n${GREEN}CloudWatch Monitoring setup complete!${NC}"
echo -e "\n${YELLOW}To configure CloudWatch Agent on EC2 instances:${NC}"
echo -e "1. Install CloudWatch Agent: aws ssm send-command \\"
echo -e "    --document-name \"AWS-ConfigureAWSPackage\" \\"
echo -e "    --parameters '{\"action\":[\"Install\"],\"name\":[\"AmazonCloudWatchAgent\"]}' \\"
echo -e "    --targets \"Key=tag:aws:autoscaling:groupName,Values=$AUTO_SCALING_GROUP_NAME\" \\"
echo -e "    --region $AWS_REGION"
echo -e "2. Configure CloudWatch Agent: aws ssm send-command \\"
echo -e "    --document-name \"AmazonCloudWatch-ManageAgent\" \\"
echo -e "    --parameters '{\"action\":[\"configure\"],\"mode\":[\"ec2\"],\"optionalConfigurationSource\":[\"ssm\"],\"optionalConfigurationLocation\":[\"AmazonCloudWatch-DevOpsPortfolio-Config\"],\"optionalRestart\":[\"yes\"]}' \\"
echo -e "    --targets \"Key=tag:aws:autoscaling:groupName,Values=$AUTO_SCALING_GROUP_NAME\" \\"
echo -e "    --region $AWS_REGION"

echo -e "\n${YELLOW}CloudWatch Dashboard URL:${NC}"
echo -e "https://$AWS_REGION.console.aws.amazon.com/cloudwatch/home?region=$AWS_REGION#dashboards:name=DevOpsPortfolio-Dashboard"
