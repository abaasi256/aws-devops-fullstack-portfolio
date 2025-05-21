#!/bin/bash

# Stop application with PM2
if command -v pm2 &> /dev/null; then
    echo "Stopping application with PM2..."
    pm2 stop devops-portfolio || true
    pm2 delete devops-portfolio || true
else
    echo "PM2 not found, stopping application with pkill..."
    pkill -f "node server.js" || true
fi

echo "ApplicationStop script completed successfully"
