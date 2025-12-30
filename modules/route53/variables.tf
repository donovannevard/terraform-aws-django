variable "domain_name" {
  description = "Primary domain name (e.g., mydjangoapp.co.uk)"
  type        = string
}

variable "hosted_zone_id" {
  description = "Existing Route 53 hosted zone ID. If empty, a new zone will be created."
  type        = string
  default     = ""
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the ALB (for alias records)"
  type        = string
}

variable "cloudfront_domain" {
  description = "Domain name of the CloudFront distribution (required)"
  type        = string
}

variable "cloudfront_zone_id" {
  description = "Hosted zone ID for CloudFront (optional, defaults to fixed value)"
  type        = string
  default     = "Z2FDTNDATAQYW2"
}

variable "create_apex_redirect" {
  description = "Create HTTP -> HTTPS redirect for apex using S3 + CloudFront (optional)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}