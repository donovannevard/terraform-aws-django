#!/bin/bash
set -euo pipefail

# Redirect all output to log file and console for debugging
exec > >(tee /var/log/user-data.log) 2>&1

echo "User data script started at $(date)"

# Update packages
yum update -y

# Install Docker if missing
if ! command -v docker >/dev/null 2>&1; then
  echo "Installing Docker..."
  amazon-linux-extras install docker -y || yum install docker -y
  systemctl start docker
  systemctl enable docker
  usermod -aG docker ec2-user
fi

# Log in to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin "${ecr_repo_url}"

# Pull image
echo "Pulling image ${ecr_repo_url}:latest"
docker pull "${ecr_repo_url}:latest"

# Stop/remove old container if exists
docker stop django-app || true
docker rm django-app || true

# Run Django container
# Adjust -p, env vars, volumes based on your Django setup
echo "Starting Django container..."
docker run -d \
  --name django-app \
  -p 8000:8000 \
  --restart unless-stopped \
  -e DATABASE_URL="postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:5432/${DB_NAME}" \
  -e SECRET_KEY="${SECRET_KEY}" \  # optional, from secrets
  -e AWS_STORAGE_BUCKET_NAME="${S3_BUCKET}" \
  -e AWS_S3_CUSTOM_DOMAIN="${CLOUDFRONT_DOMAIN}" \
  <your-ecr-repo-url>:latest

# Quick health check
sleep 10
if docker ps --filter "name=django-app" --filter "status=running" | grep -q django-app; then
  echo "Django container is running"
else
  echo "ERROR: Django container failed to start"
  docker logs django-app
  exit 1
fi

# Install CloudWatch Agent
if ! command -v /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl >/dev/null 2>&1; then
  echo "Installing CloudWatch Agent..."
  yum install -y amazon-cloudwatch-agent
fi

# CloudWatch Agent config (inline - simple CPU/mem/disk + logs)
cat <<'EOC' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "cwagent"
  },
  "metrics": {
    "append_dimensions": {
      "InstanceId": "$${aws:InstanceId}",
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}"
    },
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_active"],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["disk_used_percent"],
        "resources": ["/"],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "ec2-messages",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "ec2-cloud-init",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "ec2-user-data",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOC

# Start agent
echo "Starting CloudWatch Agent..."
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

echo "User data completed successfully at $(date)"