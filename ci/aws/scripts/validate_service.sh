#!/bin/bash

# Check if application is running
if command -v pm2 &> /dev/null; then
    echo "Validating application status with PM2..."
    pm2 status devops-portfolio
    
    # Check if the application is running
    if pm2 status devops-portfolio | grep -q "online"; then
        echo "Application is running"
    else
        echo "Application is not running"
        exit 1
    fi
else
    echo "PM2 not found, validating with process check..."
    
    # Check if the application process is running
    if pgrep -f "node server.js" > /dev/null; then
        echo "Application is running"
    else
        echo "Application is not running"
        exit 1
    fi
fi

# Check if application is responding
echo "Checking if application is responding to HTTP requests..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health)

if [ "$response" == "200" ]; then
    echo "Application is responding with HTTP 200"
else
    echo "Application is not responding properly, got HTTP $response"
    exit 1
fi

echo "ValidateService script completed successfully"
