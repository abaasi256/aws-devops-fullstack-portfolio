# CI/CD Pipeline Documentation

This document provides information about the Continuous Integration and Continuous Deployment (CI/CD) pipelines configured for this project.

## Table of Contents

- [Overview](#overview)
- [CI/CD Options](#cicd-options)
  - [AWS CodePipeline + CodeBuild](#aws-codepipeline--codebuild)
  - [GitHub Actions](#github-actions)
- [Pipeline Workflow](#pipeline-workflow)
- [Configuration Files](#configuration-files)
- [Setup Instructions](#setup-instructions)
- [Customization](#customization)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

The CI/CD pipeline automates the process of building, testing, and deploying the application. It ensures that code changes are systematically built, tested, and prepared for deployment to production, reducing manual errors and increasing delivery speed.

## CI/CD Options

This project provides two CI/CD implementation options:

### AWS CodePipeline + CodeBuild

A fully AWS-native CI/CD solution that integrates tightly with other AWS services.

#### Components

- **AWS CodePipeline**: Orchestrates the pipeline workflow
- **AWS CodeBuild**: Builds and tests the application
- **AWS CodeDeploy**: Deploys the application to EC2 instances
- **Amazon S3**: Stores pipeline artifacts

#### Benefits

- Deep integration with AWS services
- Built-in support for AWS security features
- Simplified IAM permission management
- AWS-managed infrastructure

### GitHub Actions

A GitHub-based CI/CD solution that integrates with your GitHub repository.

#### Components

- **GitHub Actions**: Defines and runs the CI/CD workflow
- **GitHub Runners**: Executes the workflow steps
- **Amazon S3**: Stores deployment artifacts
- **AWS CodeDeploy**: Deploys the application to EC2 instances

#### Benefits

- Tight integration with GitHub repositories
- Simplified configuration via YAML files
- Large ecosystem of pre-built actions
- No additional services to manage

## Pipeline Workflow

Both CI/CD options follow a similar workflow:

1. **Source**: Code changes trigger the pipeline
2. **Build**: Application is built and tested
   - Install dependencies
   - Run tests
   - Build frontend and backend
3. **Package**: Create deployment package
   - Bundle application code
   - Include deployment scripts
   - Create ZIP archive
4. **Deploy**: Deploy to EC2 instances
   - Upload package to S3
   - Trigger deployment
   - Run deployment scripts
5. **Verify**: Validate deployment success

## Configuration Files

### AWS CodePipeline + CodeBuild

- **buildspec.yml**: Defines the build process for CodeBuild
- **appspec.yml**: Defines deployment steps for CodeDeploy
- **pipeline.yml**: CloudFormation template for creating the pipeline
- **scripts/**: Deployment scripts for different lifecycle events

### GitHub Actions

- **.github/workflows/ci-cd.yml**: Defines the complete CI/CD workflow
- **appspec.yml**: Defines deployment steps for CodeDeploy
- **scripts/**: Deployment scripts for different lifecycle events

## Setup Instructions

### AWS CodePipeline + CodeBuild

1. **Prerequisite**: Ensure you have deployed the infrastructure using Terraform

2. **Configure the Pipeline**:

   ```bash
   cd ci/aws
   ./setup-pipeline.sh
   ```

   Follow the prompts to configure:
   - GitHub repository owner and name
   - GitHub OAuth token
   - AWS region
   - CloudFormation stack name

3. **Verify Pipeline Creation**:

   Go to the AWS CodePipeline console to check if the pipeline was created correctly.

### GitHub Actions

1. **Add Repository Secrets**:

   Add the following secrets to your GitHub repository:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key
   - `AWS_REGION`: The AWS region where your infrastructure is deployed
   - `S3_BUCKET`: The S3 bucket for storing deployment artifacts

2. **Push the Workflow File**:

   The workflow file `.github/workflows/ci-cd.yml` should already be in your repository. If you need to modify it, make your changes and push them to the repository.

3. **Trigger the Workflow**:

   The workflow will be triggered automatically on push to the main branch. You can also manually trigger it from the GitHub Actions tab in your repository.

## Customization

### Customizing the Build Process

#### AWS CodeBuild

Modify the `buildspec.yml` file to customize the build process:

```yaml
# Add custom build commands
build:
  commands:
    - echo "Running custom build commands..."
    - npm run custom-script
```

#### GitHub Actions

Modify the `.github/workflows/ci-cd.yml` file to customize the build process:

```yaml
# Add custom build steps
- name: Run custom build steps
  run: |
    echo "Running custom build steps..."
    npm run custom-script
```

### Customizing the Deployment Process

Modify the deployment scripts in the `scripts/` directory:

- `before_install.sh`: Run before the application is installed
- `after_install.sh`: Run after the application is installed
- `start_application.sh`: Start the application
- `stop_application.sh`: Stop the application
- `validate_service.sh`: Validate the application is running correctly

## Best Practices

- **Test Locally**: Test your CI/CD configuration locally before pushing changes
- **Secure Secrets**: Never commit secrets or credentials to your repository
- **Minimize Build Time**: Optimize your build process to reduce build time
- **Cache Dependencies**: Use caching to speed up builds
- **Monitor Pipeline**: Regularly check pipeline status and logs
- **Version Control Configuration**: Keep all CI/CD configuration files in version control
- **Document Changes**: Document any changes to the CI/CD pipeline
- **Gradual Rollout**: Consider using deployment strategies like blue/green deployments or canary releases

## Troubleshooting

### Common Issues with AWS CodePipeline

- **Pipeline Fails at Source Stage**:
  - Check GitHub repository access
  - Verify OAuth token permissions

- **CodeBuild Failures**:
  - Check build logs in CodeBuild console
  - Verify build environment configuration

- **CodeDeploy Failures**:
  - Check instance logs at `/var/log/aws/codedeploy-agent/`
  - Verify instance IAM roles

### Common Issues with GitHub Actions

- **Workflow Fails at Checkout**:
  - Check repository permissions

- **AWS Credential Issues**:
  - Verify that repository secrets are correctly set
  - Check IAM permissions of the provided credentials

- **Deployment Failures**:
  - Check GitHub Actions logs
  - Verify S3 bucket access permissions
  - Check CodeDeploy service role permissions

### Viewing Logs

#### AWS CodePipeline + CodeBuild

- **Pipeline Logs**: AWS CodePipeline console > Select pipeline > View execution details
- **Build Logs**: AWS CodeBuild console > Select build project > View build history
- **Deployment Logs**: AWS CodeDeploy console > Select deployment group > View deployments

#### GitHub Actions

- **Workflow Logs**: GitHub repository > Actions tab > Select workflow run
- **EC2 Deployment Logs**: SSH into EC2 instance > Check `/var/log/aws/codedeploy-agent/` and `/opt/app/logs/`

### Resolving Pipeline Issues

1. **Identify the Stage**: Determine which stage of the pipeline is failing
2. **Check Logs**: Examine logs for error messages
3. **Fix the Issue**: Address the specific issue identified
4. **Re-run Pipeline**: Trigger the pipeline again to verify the fix
5. **Document the Solution**: Document the issue and solution for future reference
