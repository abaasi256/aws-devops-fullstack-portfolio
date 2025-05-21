#!/bin/bash

# Configuration
STACK_NAME="devops-portfolio-pipeline"
AWS_REGION="us-east-1"
GITHUB_OWNER=""
GITHUB_REPO=""
GITHUB_TOKEN=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Get input parameters
echo -e "${YELLOW}Setting up AWS CodePipeline for DevOps Portfolio Project${NC}"
echo "-------------------------------------------------------------"

if [ -z "$GITHUB_OWNER" ]; then
    read -p "Enter GitHub repository owner: " GITHUB_OWNER
fi

if [ -z "$GITHUB_REPO" ]; then
    read -p "Enter GitHub repository name: " GITHUB_REPO
fi

if [ -z "$GITHUB_TOKEN" ]; then
    read -p "Enter GitHub OAuth token: " GITHUB_TOKEN
fi

read -p "Enter AWS region [$AWS_REGION]: " input
AWS_REGION=${input:-$AWS_REGION}

read -p "Enter CloudFormation stack name [$STACK_NAME]: " input
STACK_NAME=${input:-$STACK_NAME}

echo -e "\n${YELLOW}Validating CloudFormation template...${NC}"
aws cloudformation validate-template --template-body file://pipeline.yml --region $AWS_REGION

if [ $? -ne 0 ]; then
    echo -e "${RED}CloudFormation template validation failed. Exiting.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Creating/Updating CloudFormation stack...${NC}"
aws cloudformation deploy \
    --template-file pipeline.yml \
    --stack-name $STACK_NAME \
    --parameter-overrides \
        GitHubOwner=$GITHUB_OWNER \
        GitHubRepo=$GITHUB_REPO \
        GitHubToken=$GITHUB_TOKEN \
    --capabilities CAPABILITY_IAM \
    --region $AWS_REGION

if [ $? -ne 0 ]; then
    echo -e "${RED}CloudFormation stack deployment failed.${NC}"
    exit 1
fi

echo -e "\n${GREEN}CloudFormation stack deployed successfully!${NC}"
echo -e "\n${YELLOW}Stack outputs:${NC}"
aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query "Stacks[0].Outputs" \
    --region $AWS_REGION

echo -e "\n${GREEN}AWS CodePipeline setup complete.${NC}"
echo -e "${YELLOW}You can now push to your GitHub repository to trigger the pipeline.${NC}"
