resource "cloudflare_record" "app" {
  zone_id = var.CLOUDFLARE_ZONE_ID
  name    = local.cloudflare_subdomain
  content = aws_lb.alb.dns_name
  type    = "CNAME"
  proxied = true # This enables Cloudflare proxy (orange cloud)
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "shared_vpc" {
  backend = "s3"
  config = {
    region = var.AWS_REGION
    bucket = var.REMOTE_STATE_BUCKET
    key    = "infrastructure/terraform.tfstate"
  }
}
