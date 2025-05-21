#!/bin/bash

# Navigate to application directory
cd /opt/app

# Start application with PM2
if command -v pm2 &> /dev/null; then
    echo "Starting application with PM2..."
    pm2 start server.js --name "devops-portfolio" --time
    
    # Save PM2 configuration
    pm2 save
    
    # Set PM2 to start on system startup
    pm2 startup | tail -n 1 | bash
else
    echo "PM2 not found, starting application with Node.js..."
    nohup node server.js > app.log 2>&1 &
fi

echo "ApplicationStart script completed successfully"
