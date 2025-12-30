# modules/ses/outputs.tf

output "domain_identity_arn" {
  description = "ARN of the SES domain identity"
  value       = aws_ses_domain_identity.main.arn
}

output "domain_identity_verification_token" {
  description = "Verification token to place in Route 53 TXT record for domain ownership"
  value       = aws_ses_domain_identity.main.verification_token
}

output "dkim_tokens" {
  description = "DKIM tokens (CNAME records) to add to Route 53 for email signing"
  value       = aws_ses_domain_dkim.main.dkim_tokens
}

output "ses_identity_id" {
  description = "The SES domain identity ID (usually the domain name)"
  value       = aws_ses_domain_identity.main.id
}

output "verification_record_name" {
  description = "Suggested Route 53 record name for SES domain verification TXT record"
  value       = "_amazonses.${var.domain_name}"
}

output "verification_record_value" {
  description = "Value for the SES verification TXT record"
  value       = aws_ses_domain_identity.main.verification_token
}

# If you add email identities (e.g., noreply@domain.com)
output "email_identity_arns" {
  description = "ARNs of any verified email identities"
  value       = { for k, v in aws_ses_email_identity.sender : k => v.arn }
}