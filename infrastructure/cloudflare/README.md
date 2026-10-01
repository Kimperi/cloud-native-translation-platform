# Cloudflare infrastructure

This Terraform configuration adopts the existing Cloudflare Pages project and
R2 bucket. It does not contain credentials, R2 objects, or application secrets.

## Prerequisites

- Terraform 1.5 or newer
- A Cloudflare API token with `Pages Write` and `Workers R2 Storage Write`
- The Cloudflare account ID

Set credentials in the current shell. Do not place the token in a `.tfvars`
file:

```powershell
$env:CLOUDFLARE_API_TOKEN = "your-token"
$env:TF_VAR_cloudflare_account_id = "your-account-id"
```

## Adopt the existing resources

The resources already exist, so import them before running `terraform apply`.
Running apply before import would try to create resources with duplicate names.

```powershell
cd infrastructure/cloudflare
terraform init

terraform import cloudflare_pages_project.frontend `
  "$env:TF_VAR_cloudflare_account_id/translation-platform-frontend"

terraform import cloudflare_r2_bucket.translations `
  "$env:TF_VAR_cloudflare_account_id/translation-platform-i18n/default"

terraform plan
```

Review the plan carefully. The expected result after import is no destructive
change. Both resources use `prevent_destroy` as an additional safeguard.

Terraform state is local and ignored by Git. For individual portfolio use,
store a backup securely. A remote state backend can be introduced later when
the project needs team collaboration.
