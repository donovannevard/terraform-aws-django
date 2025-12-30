variable "domain_name" {
  description = "The domain name (e.g., example.com)"
  type        = string
}

variable "hosted_zone_id" {
  description = "Existing Route 53 hosted zone ID (optional)"
  type        = string
  default     = ""
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "Hosted zone ID of the ALB"
  type        = string
}

variable "cloudfront_domain" {
  description = "Domain name of the CloudFront distribution (required)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}