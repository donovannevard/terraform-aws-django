terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Certificate for ALB (eu-west-2 default region)
resource "aws_acm_certificate" "alb" {
  domain_name               = var.domain_name
  subject_alternative_names = var.alternative_names
  validation_method         = "EMAIL"

  tags = merge(var.tags, {
    Name = "alb-cert"
    Use  = "ALB HTTPS"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Certificate for CloudFront (must be in us-east-1)
resource "aws_acm_certificate" "cloudfront" {
  provider = aws.us_east_1

  domain_name               = var.domain_name
  subject_alternative_names = var.alternative_names
  validation_method         = "EMAIL"  # Email validation

  tags = merge(var.tags, {
    Name = "cloudfront-cert"
    Use  = "CloudFront"
  })

  lifecycle {
    create_before_destroy = true
  }
}