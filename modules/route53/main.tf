# Always create a new hosted zone for the domain
resource "aws_route53_zone" "this" {
  name = var.domain_name

  tags = merge(var.tags, {
    Name = "${replace(var.domain_name, ".", "-")}-zone"
  })
}

locals {
  zone_id            = aws_route53_zone.this.zone_id
  cloudfront_zone_id = "Z2FDTNDATAQYW2"  # Fixed global CloudFront zone ID
}

# A record: apex -> CloudFront
resource "aws_route53_record" "apex" {
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain
    zone_id                = local.cloudfront_zone_id
    evaluate_target_health = false
  }

  lifecycle {
    ignore_changes = [alias]
  }
}

# AAAA record: apex -> CloudFront
resource "aws_route53_record" "apex_ipv6" {
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = var.cloudfront_domain
    zone_id                = local.cloudfront_zone_id
    evaluate_target_health = false
  }

  lifecycle {
    ignore_changes = [alias]
  }
}

# A record: www -> CloudFront
resource "aws_route53_record" "www" {
  zone_id = local.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain
    zone_id                = local.cloudfront_zone_id
    evaluate_target_health = false
  }

  lifecycle {
    ignore_changes = [alias]
  }
}

# AAAA record: www -> CloudFront
resource "aws_route53_record" "www_ipv6" {
  zone_id = local.zone_id
  name    = "www.${var.domain_name}"
  type    = "AAAA"

  alias {
    name                   = var.cloudfront_domain
    zone_id                = local.cloudfront_zone_id
    evaluate_target_health = false
  }

  lifecycle {
    ignore_changes = [alias]
  }
}