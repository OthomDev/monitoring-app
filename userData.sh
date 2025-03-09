#!/bin/bash
set -e  # Exit immediately if a command fails

# Update the system and install python3, pip, flask, and psutil
sudo apt update -y
sudo apt install -y python3 python3-pip python3-flask python3-psutil git


# Clone Flask Monitoring App from GitHub
cd /home/ubuntu
git clone https://github.com/OthomDev/monitoring-app.git

# Move into the correct folder where the Flask app is located
cd /home/ubuntu/monitoring-app/python-app

# Ensure the Flask app directory exists
mkdir -p /home/ubuntu/python-app

# Copy application files to the target directory
cp -r /home/ubuntu/monitoring-app/python-app/* /home/ubuntu/python-app/

# Move into the application directory
cd /home/ubuntu/python-app


# Set correct permissions
sudo chown -R ubuntu:ubuntu .
sudo chmod 644 flask.log || touch flask.log && sudo chmod 644 flask.log

# Run Flask App
nohup python3 app.py > flask.log 2>&1 &
