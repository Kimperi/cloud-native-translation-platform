# Cloudflare infrastructure

This Terraform configuration manages the existing Cloudflare Pages project and
translation R2 bucket. Terraform state is stored in a separate private R2
bucket through Terraform's S3-compatible backend.

The repository contains no credentials, state files, R2 objects, or application
secrets.

## Managed resources

- Pages project: `translation-platform-frontend`
- Translation bucket: `translation-platform-i18n`
- Remote-state bucket: `translation-platform-terraform-state`
- Remote-state object: `cloudflare/terraform.tfstate`

The state bucket is a bootstrap resource. Create it manually and do not add it
to this same Terraform state, because Terraform cannot initialize its backend
from a bucket that it has not created yet.

## 1. Create the private state bucket

In Cloudflare, open **R2 object storage**, select **Create bucket**, and use:

```text
translation-platform-terraform-state
```

Keep the bucket private. Do not enable an `r2.dev` URL or a public custom
domain.

Under **Manage R2 API tokens**, create a token with **Object Read & Write**
access scoped only to `translation-platform-terraform-state`. Save its Access
Key ID and Secret Access Key in a password manager.

These S3-compatible credentials are separate from `CLOUDFLARE_API_TOKEN`,
which Terraform uses to manage Pages and R2 bucket configuration.

## 2. Load credentials

Set credentials only in the current PowerShell session:

```powershell
$env:CLOUDFLARE_API_TOKEN = [System.Net.NetworkCredential]::new(
    "",
    (Read-Host "Cloudflare management token" -AsSecureString)
).Password

$env:AWS_ACCESS_KEY_ID = Read-Host "R2 state Access Key ID"

$env:AWS_SECRET_ACCESS_KEY = [System.Net.NetworkCredential]::new(
    "",
    (Read-Host "R2 state Secret Access Key" -AsSecureString)
).Password

$env:TF_VAR_cloudflare_account_id = "your-account-id"
```

The Cloudflare management token needs `Cloudflare Pages Edit` and
`Workers R2 Storage Edit` for the selected account.

## 3. Migrate existing local state

From this directory, run:

```powershell
terraform init -migrate-state
```

Terraform asks whether to copy the existing local state to R2. Review the
backend name and answer `yes`. This operation uploads state; it does not modify
the Pages project or translation bucket.

Verify the migrated state:

```powershell
terraform state list
terraform plan
```

The expected plan is:

```text
No changes. Your infrastructure matches the configuration.
```

## Adopt resources in a fresh state

Only use these imports if the remote state is empty. Existing resources must
be imported before any apply:

```powershell
terraform import cloudflare_pages_project.frontend `
  "$env:TF_VAR_cloudflare_account_id/translation-platform-frontend"

terraform import cloudflare_r2_bucket.translations `
  "$env:TF_VAR_cloudflare_account_id/translation-platform-i18n/default"
```

Never import a resource a second time when it is already listed by
`terraform state list`.

## Safety rules

- Never commit `.tfstate` files or backend credentials.
- Never make the state bucket public.
- Use a dedicated R2 token scoped only to the state bucket.
- Run `terraform plan` and review it before every apply.
- Do not apply a plan that recreates an existing resource.
- Both application resources use `prevent_destroy` as an additional safeguard.
