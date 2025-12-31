variable "domain_name" {
  description = "Primary domain name (e.g., mydjangoapp.co.uk or www.mydjangoapp.co.uk)"
  type        = string
}

variable "alternative_names" {
  description = "Additional SANs (e.g., ['www.mydjangoapp.co.uk'] if primary is apex)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to certificates"
  type        = map(string)
  default     = {}
}