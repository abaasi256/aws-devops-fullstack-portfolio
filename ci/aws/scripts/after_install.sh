#!/bin/bash

cd /opt/app

# Install backend dependencies
echo "Installing backend dependencies..."
npm install --production

# Create environment file from SSM parameters
if [ "$NODE_ENV" == "production" ]; then
    echo "Setting up environment variables from SSM Parameter Store..."
    
    # Get database connection parameters from SSM Parameter Store
    DB_ENDPOINT=$(aws ssm get-parameter --name "/devops-portfolio/prod/db_endpoint" --with-decryption --query "Parameter.Value" --output text || echo "localhost")
    DB_NAME=$(aws ssm get-parameter --name "/devops-portfolio/prod/db_name" --with-decryption --query "Parameter.Value" --output text || echo "appdb")
    DB_USERNAME=$(aws ssm get-parameter --name "/devops-portfolio/prod/db_username" --with-decryption --query "Parameter.Value" --output text || echo "admin")
    DB_PASSWORD=$(aws ssm get-parameter --name "/devops-portfolio/prod/db_password" --with-decryption --query "Parameter.Value" --output text || echo "password")
    
    # Create .env file
    cat > .env << EOF
DB_HOST=$DB_ENDPOINT
DB_PORT=3306
DB_USER=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME
PORT=3000
NODE_ENV=production
JWT_SECRET=$(openssl rand -hex 32)
JWT_EXPIRES_IN=1d
LOG_LEVEL=info
EOF
else
    # Create a default .env file for non-production environments
    cat > .env << EOF
DB_HOST=localhost
DB_PORT=3306
DB_USER=admin
DB_PASSWORD=password
DB_NAME=appdb
PORT=3000
NODE_ENV=development
JWT_SECRET=devops-portfolio-development-secret
JWT_EXPIRES_IN=1d
LOG_LEVEL=debug
EOF
fi

# Set the correct permissions
chown -R ec2-user:ec2-user /opt/app
chmod -R 755 /opt/app

echo "AfterInstall script completed successfully"
