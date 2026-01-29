output "app_url" {
  value       = "https://${local.cloudflare_subdomain}.${local.cloudflare_domain}"
  description = "Base URL for the Google Workspace MCP server."
}
