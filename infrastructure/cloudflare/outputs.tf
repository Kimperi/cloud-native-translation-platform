output "pages_project_name" {
  description = "Cloudflare Pages project managed by this configuration."
  value       = cloudflare_pages_project.frontend.name
}

output "pages_subdomain" {
  description = "Default Pages subdomain returned by Cloudflare."
  value       = cloudflare_pages_project.frontend.subdomain
}

output "r2_bucket_name" {
  description = "R2 bucket managed by this configuration."
  value       = cloudflare_r2_bucket.translations.name
}
