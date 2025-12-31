variable "zone_id" {
  description = "ID of the Route 53 hosted zone"
  type        = string
}

variable "domain_name" {
  description = "The domain name (e.g. nevard.dev)"
  type        = string
}

variable "cloudfront_domain" {
  description = "CloudFront distribution domain name (e.g. d123abc.cloudfront.net)"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB (optional fallback)"
  type        = string
  default     = ""
}

variable "alb_zone_id" {
  description = "Hosted zone ID of the ALB (optional fallback)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}