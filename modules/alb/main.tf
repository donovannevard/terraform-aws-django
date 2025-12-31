resource "aws_lb" "this" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false  # Set true for prod later

  access_logs {
    bucket  = var.access_logs_bucket
    enabled = var.access_logs_bucket != ""
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-alb"
  })
}

# Security Group for ALB (allow 80/443 from anywhere)
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow inbound HTTP/HTTPS to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-alb-sg"
  })
}

# Target Group for the single EC2 instance (port 8000 - adjust if your Django container uses different)
resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-tg"
  port     = 8000  # Gunicorn/Django default - change if needed
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"  # Or /health/ if you have a health endpoint
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-tg"
  })
}

# Attach the ASG to the ALB target group (correct for Auto Scaling Group)
resource "aws_autoscaling_attachment" "app" {
  autoscaling_group_name = var.autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.app.arn
}

# AWS WAFv2 Web ACL - Basic protection with AWS Managed Common Rule Set
resource "aws_wafv2_web_acl" "app" {
  name  = "${var.project_name}-waf"
  scope = "REGIONAL"  # Required for ALB

  default_action {
    allow {}  # Allow traffic unless a rule blocks it
  }

  # AWS Managed Rules: Common Rule Set (covers OWASP Top 10 basics, SQLi, XSS, etc.)
  rule {
    name     = "AWSManagedCommonRules"
    priority = 1

    override_action {
      none {}  # Use the managed rule's built-in action (usually block on match)
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"

        # Optional: If a rule is too noisy (rare at start), exclude it like this:
        # excluded_rule {
        #   name = "SizeRestrictions_BODY"  # Example
        # }
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-common-rules"
    }
  }

  # Overall visibility (shows total requests + blocked in CloudWatch)
  visibility_config {
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-waf"
  }

  tags = var.tags
}

# Associate the Web ACL with your ALB
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.this.arn
  web_acl_arn  = aws_wafv2_web_acl.app.arn
}

# HTTPS Listener (443) - forward to target group
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"  # Strong modern policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# HTTP Listener (80) - redirect to HTTPS
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}