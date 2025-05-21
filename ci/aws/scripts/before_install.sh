#!/bin/bash

# Update package lists
yum update -y

# Install Node.js
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
    yum install -y nodejs
fi

# Install PM2 globally
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2..."
    npm install -g pm2
fi

# Create application directory if it doesn't exist
if [ ! -d "/opt/app" ]; then
    mkdir -p /opt/app
    chown ec2-user:ec2-user /opt/app
fi

# Stop any running application processes
if command -v pm2 &> /dev/null; then
    pm2 stop all || true
    pm2 delete all || true
fi

# Clean up old deployment
rm -rf /opt/app/*

echo "BeforeInstall script completed successfully"
