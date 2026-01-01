# Validation for ALB cert
resource "cloudflare_record" "alb_validation" {
  zone_id = var.cloudflare_zone_id
  name    = aws_acm_certificate.alb.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.alb.domain_validation_options.0.resource_record_type
  value   = aws_acm_certificate.alb.domain_validation_options.0.resource_record_value
  ttl     = 60
}

resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb.arn
  validation_record_fqdns = [cloudflare_record.alb_validation.hostname]
}

# Same for CloudFront
resource "cloudflare_record" "cloudfront_validation" {
  zone_id = var.cloudflare_zone_id
  name    = aws_acm_certificate.cloudfront.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cloudfront.domain_validation_options.0.resource_record_type
  value   = aws_acm_certificate.cloudfront.domain_validation_options.0.resource_record_value
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cloudfront" {
  provider = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [cloudflare_record.cloudfront_validation.hostname]
}