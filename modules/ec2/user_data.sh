#!/bin/bash

# Pull and run Docker image (your existing logic)
docker login -u AWS -p $(aws ecr get-login-password --region ${AWS::Region}) ${ecr_repo_url}
docker pull ${ecr_repo_url}:latest
docker run -d -p 8000:8000 --name django-app ${ecr_repo_url}:latest
# Add Django migrate/collectstatic if needed

# Install and configure CloudWatch Agent
yum update -y
yum install -y amazon-cloudwatch-agent

# Fetch config from local (or SSM if you add aws_ssm_parameter)
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
$(cat cw_agent_config.json)  # Inline your config or copy from Terraform
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s