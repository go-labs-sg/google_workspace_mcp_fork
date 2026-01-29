variable "ENVIRONMENT" {
  description = "The environment to deploy resources in."
  type        = string
}

variable "REMOTE_STATE_BUCKET" {
  description = "The bucket to get shared Terraform state file."
  type        = string
}

variable "AWS_REGION" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-southeast-1"
}

variable "DEV_EMAILS" {
  description = "A list of developer email addresses for alert notifications."
  type        = list(string)
  default     = ["noah@getout.sg"]
}

variable "ECR_REPO_URI" {
  type      = string
  sensitive = true
  default   = "google-workspace-mcp"
}

variable "ECR_IMAGE_DIGEST" {
  type      = string
  sensitive = true
  default   = "sha256:1234567890"
}

variable "CLOUDFLARE_ZONE_ID" {
  type      = string
  sensitive = true
}

variable "CLOUDFLARE_API_TOKEN" {
  description = "API token for managing Cloudflare."
  type        = string
  sensitive   = true
}

variable "CLOUDFLARE_DOMAIN" {
  type      = string
  sensitive = true
}

variable "CERTIFICATE_ARN" {
  type      = string
  sensitive = true
}

variable "GOOGLE_OAUTH_CLIENT_ID" {
  type      = string
  sensitive = true
}

variable "GOOGLE_OAUTH_CLIENT_SECRET" {
  type      = string
  sensitive = true
}

variable "MCP_ENABLE_OAUTH21" {
  type    = string
  default = "true"
}

variable "WORKSPACE_MCP_STATELESS_MODE" {
  type    = string
  default = "true"
}

variable "WORKSPACE_EXTERNAL_URL" {
  type = string
}

variable "WORKSPACE_MCP_PORT" {
  type    = string
  default = "8000"
}

variable "WORKSPACE_MCP_BASE_URI" {
  type    = string
  default = ""
}

variable "EXTERNAL_OAUTH21_PROVIDER" {
  type    = string
  default = "false"
}

variable "OAUTH_CUSTOM_REDIRECT_URIS" {
  type    = string
  default = ""
}

variable "OAUTH_ALLOWED_ORIGINS" {
  type    = string
  default = ""
}

variable "TOOL_TIER" {
  type    = string
  default = ""
}

variable "TOOLS" {
  type    = string
  default = ""
}
