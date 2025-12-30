# Create new hosted zone if no existing ID provided
resource "aws_route53_zone" "this" {
  count = var.hosted_zone_id == "" ? 1 : 0

  name = var.domain_name

  tags = merge(var.tags, {
    Name = "${replace(var.domain_name, ".", "-")}-zone"
  })
}

# Use existing or newly created zone ID
locals {
  zone_id = var.hosted_zone_id != "" ? var.hosted_zone_id : aws_route53_zone.this[0].zone_id
}

# CloudFront hosted zone ID (fixed value for all CloudFront distributions)
locals {
  cloudfront_zone_id = "Z2FDTNDATAQYW2"
}

# A record: apex domain -> CloudFront
resource "aws_route53_record" "apex" {
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain
    zone_id                = local.cloudfront_zone_id
    evaluate_target_health = false  # CloudFront does not support target health evaluation
  }

  depends_on = [
    aws_acm_certificate_validation.cloudfront  # Ensure validation completes first (if in same module or root)
  ]
}

# AAAA record for IPv6 (CloudFront supports it)
resource "aws_route53_record" "apex_ipv6" {
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = var.cloudfront_domain
    zone_id                = local.cloudfront_zone_id
    evaluate_target_health = false
  }

  depends_on = [
    aws_acm_certificate_validation.cloudfront
  ]
}

# www -> CloudFront
resource "aws_route53_record" "www" {
  zone_id = local.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain
    zone_id                = local.cloudfront_zone_id
    evaluate_target_health = false
  }

  depends_on = [
    aws_acm_certificate_validation.cloudfront
  ]
}

# IPv6 for www
resource "aws_route53_record" "www_ipv6" {
  zone_id = local.zone_id
  name    = "www.${var.domain_name}"
  type    = "AAAA"

  alias {
    name                   = var.cloudfront_domain
    zone_id                = local.cloudfront_zone_id
    evaluate_target_health = false
  }

  depends_on = [
    aws_acm_certificate_validation.cloudfront
  ]
}