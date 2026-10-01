variable "cloudflare_account_id" {
  description = "Cloudflare account that owns the Pages project and R2 bucket."
  type        = string
}

variable "pages_project_name" {
  description = "Existing Cloudflare Pages project used by Frontend CD."
  type        = string
  default     = "translation-platform-frontend"
}

variable "r2_bucket_name" {
  description = "Existing R2 bucket containing immutable translation artifacts."
  type        = string
  default     = "translation-platform-i18n"
}
