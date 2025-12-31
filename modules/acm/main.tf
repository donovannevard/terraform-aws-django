# Certificate for ALB
resource "aws_acm_certificate" "alb" {
  domain_name               = var.domain_name
  subject_alternative_names = var.alternative_names
  validation_method         = "DNS"

  tags = merge(var.tags, {
    Name = "alb-cert"
    Use  = "ALB HTTPS"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation record for ALB cert
resource "aws_route53_record" "alb_validation" {
  zone_id = var.hosted_zone_id
  name    = aws_acm_certificate.alb.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.alb.domain_validation_options.0.resource_record_type
  records = [aws_acm_certificate.alb.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb.arn
  validation_record_fqdns = [aws_route53_record.alb_validation.fqdn]
}

# Certificate for CloudFront (us-east-1)
resource "aws_acm_certificate" "cloudfront" {
  provider = aws.us_east_1

  domain_name               = var.domain_name
  subject_alternative_names = var.alternative_names
  validation_method         = "DNS"

  tags = merge(var.tags, {
    Name = "cloudfront-cert"
    Use  = "CloudFront"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation record for CloudFront cert
resource "aws_route53_record" "cloudfront_validation" {
  zone_id = var.hosted_zone_id
  name    = aws_acm_certificate.cloudfront.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cloudfront.domain_validation_options.0.resource_record_type
  records = [aws_acm_certificate.cloudfront.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cloudfront" {
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [aws_route53_record.cloudfront_validation.fqdn]
}