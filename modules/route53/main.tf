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
  zone_id            = var.hosted_zone_id != "" ? var.hosted_zone_id : aws_route53_zone.this[0].zone_id
  cloudfront_zone_id = "Z2FDTNDATAQYW2"  # Fixed CloudFront hosted zone ID
}

# A record: apex domain -> CloudFront
resource "aws_route53_record" "apex" {
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain
    zone_id                = local.cloudfront_zone_id
    evaluate_target_health = false
  }

  # Ignore alias changes after initial creation to break cycle
  lifecycle {
    ignore_changes = [alias[0].name, alias[0].zone_id]
  }
}

# AAAA record: apex -> CloudFront (IPv6)
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
    ignore_changes = [alias[0].name, alias[0].zone_id]
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
    ignore_changes = [alias[0].name, alias[0].zone_id]
  }
}

# AAAA record: www -> CloudFront (IPv6)
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
    ignore_changes = [alias[0].name, alias[0].zone_id]
  }
}