#!/bin/bash
# Base init script for EC2 Docker host

sudo apt-get update -y
sudo apt-get install -y docker.io docker-compose awscli curl

sudo systemctl start docker
sudo systemctl enable docker

# Install CloudWatch Agent
cd /tmp
sudo curl -O https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb

# Enable CloudWatch agent on boot
sudo systemctl enable amazon-cloudwatch-agent

# Simple CloudWatch config placeholder
cat <<EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/lib/docker/containers/*/*.log",
            "log_group_name": "/multi-service/app",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

sudo systemctl start amazon-cloudwatch-agent
