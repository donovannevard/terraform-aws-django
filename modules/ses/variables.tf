module "ses" {
  source          = "./modules/ses"
  domain_name     = var.domain_name
  hosted_zone_id  = var.hosted_zone_id
}