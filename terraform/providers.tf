terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.AWS_REGION
}

provider "cloudflare" {
  api_token = var.CLOUDFLARE_API_TOKEN
}
