# Certificate for ALB (uses default provider → eu-west-2)
resource "aws_acm_certificate" "alb" {
  domain_name               = var.domain_name
  subject_alternative_names = var.alternative_names
  validation_method         = "EMAIL"

  tags = merge(var.tags, {
    Name = "alb-cert-${var.domain_name}"
    Use  = "ALB HTTPS"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Certificate for CloudFront (MUST be in us-east-1)
resource "aws_acm_certificate" "cloudfront" {
  provider = aws.us_east_1

  domain_name               = var.domain_name
  subject_alternative_names = var.alternative_names
  validation_method         = "EMAIL"

  tags = merge(var.tags, {
    Name = "cloudfront-cert-${var.domain_name}"
    Use  = "CloudFront"
  })

  lifecycle {
    create_before_destroy = true
  }
}