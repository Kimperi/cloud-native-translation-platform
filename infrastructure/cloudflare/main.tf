resource "cloudflare_pages_project" "frontend" {
  account_id        = var.cloudflare_account_id
  name              = var.pages_project_name
  production_branch = "main"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_r2_bucket" "translations" {
  account_id = var.cloudflare_account_id
  name       = var.r2_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}
