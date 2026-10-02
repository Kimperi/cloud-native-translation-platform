# Cloud-Native Translation Platform

> A multilingual asset-management platform that turns source content into
> versioned translation releases, validates those releases in CI, and deploys a
> localized Angular application through a secure cloud delivery pipeline.

[![Frontend CI](https://github.com/Kimperi/cloud-native-translation-platform/actions/workflows/frontend-ci.yml/badge.svg?branch=main)](https://github.com/Kimperi/cloud-native-translation-platform/actions/workflows/frontend-ci.yml)
[![Asset Management CI](https://github.com/Kimperi/cloud-native-translation-platform/actions/workflows/asset-management-ci.yml/badge.svg?branch=main)](https://github.com/Kimperi/cloud-native-translation-platform/actions/workflows/asset-management-ci.yml)
[![Security CI](https://github.com/Kimperi/cloud-native-translation-platform/actions/workflows/security-ci.yml/badge.svg?branch=main)](https://github.com/Kimperi/cloud-native-translation-platform/actions/workflows/security-ci.yml)
[![Terraform CI](https://github.com/Kimperi/cloud-native-translation-platform/actions/workflows/terraform-ci.yml/badge.svg?branch=main)](https://github.com/Kimperi/cloud-native-translation-platform/actions/workflows/terraform-ci.yml)
[![Uptime Monitor](https://github.com/Kimperi/cloud-native-translation-platform/actions/workflows/uptime-monitor.yml/badge.svg?branch=main)](https://github.com/Kimperi/cloud-native-translation-platform/actions/workflows/uptime-monitor.yml)

**Live services:** [Frontend](https://translation-platform-frontend.pages.dev) ·
[Swagger API](https://aitranslationsplatformpoc.onrender.com/docs) ·
[Health check](https://aitranslationsplatformpoc.onrender.com/health)

> [!NOTE]
> The API uses Render's free service tier. Its first response after a period of
> inactivity can take approximately 50 seconds while the service wakes up.

## Product preview

The same Angular application is compiled and deployed in English, French, and
German. Localization covers navigation, forms, validation-facing text, asset
controls, and report actions—not only the landing-page copy.

<table>
  <tr>
    <td width="33%"><img src="docs/screenshots/frontend-en.png" alt="English localized interface"></td>
    <td width="33%"><img src="docs/screenshots/frontend-fr.png" alt="French localized interface"></td>
    <td width="33%"><img src="docs/screenshots/frontend-de.png" alt="German localized interface"></td>
  </tr>
  <tr>
    <td align="center"><strong>English</strong></td>
    <td align="center"><strong>Français</strong></td>
    <td align="center"><strong>Deutsch</strong></td>
  </tr>
</table>

<p align="center">
  <img src="docs/screenshots/asset-management.png" alt="Asset management CRUD interface and PDF report action" width="88%">
</p>

## What this project demonstrates

- A responsive Angular 21 interface localized with Angular i18n and XLIFF 1.2.
- Asset creation, listing, editing, deletion, status handling, ownership, and
  reusable tags through a documented FastAPI REST API.
- Localized PDF reports generated from live asset data in English, French, or
  German.
- Automated translation through Azure Translator, followed by structural and
  source-parity validation before publication.
- Immutable, explicitly selected translation releases stored in Cloudflare R2.
- Promotion of the exact frontend artifact that passed tests into Cloudflare
  Pages—without rebuilding during deployment.
- Layered CI, container checks, security scanning, scheduled uptime monitoring,
  and Terraform-managed Cloudflare resources.

## Overall architecture

```mermaid
flowchart LR
    subgraph Application["Application"]
        User["User"] --> Frontend["Angular frontend<br/>Cloudflare Pages"]
        Frontend --> API["FastAPI backend<br/>Render"]
        API --> Database[("Assets database")]
        API --> Reports["Localized PDF reports"]
    end

    subgraph Delivery["Translation and delivery"]
        GitHub["GitHub repository"] --> Translation["Translation workflow"]
        Translation <-->|"translate"| Azure["Azure Translator"]
        Translation --> R2[("Versioned translations<br/>Cloudflare R2")]
        GitHub --> CICD["GitHub Actions<br/>test · secure · deploy"]
        R2 --> CICD
        CICD --> Frontend
        GitHub -->|"backend deployment"| API
    end

    Terraform["Terraform<br/>Cloudflare infrastructure"] -.-> Frontend
    Terraform -.-> R2
    Monitor["Uptime monitor"] -.-> Frontend
    Monitor -.-> API

    classDef app fill:#e8f0fe,stroke:#315ddc,color:#111827;
    classDef delivery fill:#ecfdf3,stroke:#16803b,color:#111827;
    classDef operations fill:#fff7e6,stroke:#c97800,color:#111827;
    class Frontend,API,Database,Reports app;
    class GitHub,Translation,Azure,R2,CICD delivery;
    class Terraform,Monitor operations;
```

### How it works

1. The translation workflow converts the English XLIFF and JSON catalogs into
   French and German with Azure Translator, then stores a versioned release in
   Cloudflare R2.
2. GitHub Actions downloads the selected release, tests and secures the code,
   and deploys the validated frontend to Cloudflare Pages. Render deploys the
   FastAPI backend.
3. The browser calls the API to manage assets and download localized reports;
   Terraform manages the Cloudflare resources and scheduled checks monitor the
   deployed services.

## Components

| Component | Responsibility | Technology | Runtime / target |
| --- | --- | --- | --- |
| `FrontendApp` | Localized UI and API integration | Angular 21, TypeScript, RxJS, nginx | Cloudflare Pages |
| `AssetManagementService` | Asset CRUD, persistence, health endpoint, localized PDF reports | FastAPI, SQLAlchemy, Alembic, ReportLab | Render |
| `TranslationService` | Azure translation, XLIFF/JSON generation, validation, and R2 publication | Python, FastAPI, boto3 | GitHub Actions / local API |
| `infrastructure/cloudflare` | Pages and R2 resource definitions, remote-state configuration | Terraform, Cloudflare provider | Cloudflare |
| `.github/workflows` | CI, CD, security, release publication, IaC validation, uptime checks | GitHub Actions | GitHub-hosted runners |

The Asset Management service uses SQLite when `DATABASE_URL` is absent. Its CI
pipeline exercises the same SQLAlchemy models and Alembic migrations against
PostgreSQL 16.

## API surface

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/health` | Service readiness check; returns `{"status":"ok"}` |
| `GET` | `/assets` | List assets with tags |
| `POST` | `/assets` | Create an asset |
| `GET` | `/assets/{asset_id}` | Retrieve one asset |
| `PATCH` | `/assets/{asset_id}` | Update an existing asset |
| `DELETE` | `/assets/{asset_id}` | Delete an asset |
| `POST` | `/reports` | Generate an `en`, `fr`, or `de` PDF report |

<p align="center">
  <img src="docs/screenshots/api-swagger.png" alt="FastAPI Swagger documentation for the deployed Asset Management service" width="88%">
</p>

<details>
<summary><strong>View successful API responses</strong></summary>

| Asset query | Health check |
| --- | --- |
| ![GET assets returning HTTP 200 and persisted asset data](docs/screenshots/api-assets-response.png) | ![GET health returning HTTP 200 and status ok](docs/screenshots/api-health.png) |

</details>

## Delivery pipeline

| Workflow | Trigger | Main responsibility |
| --- | --- | --- |
| **Translation Publish** | Manual release | Extract source catalogs, call Azure Translator, validate, publish an immutable R2 version, and optionally dispatch Frontend CI |
| **Frontend CI** | Push, pull request, or manual release input | Audit dependencies, run Vitest, verify XLIFF parity, build all locales, validate the container and security headers, upload the build artifact |
| **Frontend CD** | Successful eligible Frontend CI run or reviewed manual dispatch | Download the exact CI artifact, enforce branch rules, deploy to Cloudflare Pages, smoke-test localized routes |
| **Asset Management CI** | Push, pull request, or manual dispatch | Download selected JSON catalogs, migrate PostgreSQL, run tests, build the backend image |
| **Translation Service CI** | Translation-service changes or manual dispatch | Install the Python package and run the translation test suite |
| **Security CI** | Push or pull request to `main` | Scan Git history with Gitleaks, analyze Python and TypeScript with CodeQL, scan filesystems and both images with Trivy |
| **Terraform CI** | Infrastructure changes | Enforce Terraform formatting and validate the Cloudflare configuration |
| **Uptime Monitor** | Every six hours or manual dispatch | Check all three frontend routes and verify the API health JSON |

### Operational evidence

<table>
  <tr>
    <td width="50%"><img src="docs/screenshots/translation-publish.png" alt="Successful versioned translation publication workflow"></td>
    <td width="50%"><img src="docs/screenshots/r2-versioned-translations.png" alt="Versioned XLIFF artifacts stored in Cloudflare R2"></td>
  </tr>
  <tr>
    <td align="center"><strong>Immutable translation release</strong></td>
    <td align="center"><strong>Versioned R2 artifacts</strong></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/frontend-ci.png" alt="Successful frontend CI with unit and container checks"></td>
    <td><img src="docs/screenshots/frontend-cd.png" alt="Successful frontend deployment to Cloudflare Pages"></td>
  </tr>
  <tr>
    <td align="center"><strong>Validated localized build</strong></td>
    <td align="center"><strong>Artifact promotion to Pages</strong></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/security-ci.png" alt="Successful Gitleaks, CodeQL, and Trivy security jobs"></td>
    <td><img src="docs/screenshots/terraform-ci.png" alt="Successful Terraform format and validation job"></td>
  </tr>
  <tr>
    <td align="center"><strong>Layered security checks</strong></td>
    <td align="center"><strong>Infrastructure validation</strong></td>
  </tr>
</table>

<details>
<summary><strong>Additional deployment and monitoring evidence</strong></summary>

| Backend deployment | Scheduled monitoring |
| --- | --- |
| ![Successful Render backend deployment](docs/screenshots/render-deployment.png) | ![Successful scheduled uptime monitor](docs/screenshots/uptime-monitor.png) |

</details>

## Run locally

### Prerequisites

- Python 3.13
- Node.js 22 or newer and npm
- Docker, when running PostgreSQL or validating containers

### Asset Management Service

```powershell
cd AssetManagementService
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements-dev.txt
python -m alembic upgrade head
python -m pytest -q
python -m uvicorn app.main:app --reload
```

The service starts at `http://127.0.0.1:8000`; Swagger is available at
`http://127.0.0.1:8000/docs`. Without `DATABASE_URL`, it creates a local SQLite
database below `AssetManagementService/data/`.

To run PostgreSQL instead:

```powershell
cd AssetManagementService
docker compose up -d postgres
$env:DATABASE_URL = "postgresql+psycopg://asset_user:asset_password@localhost:5432/asset_management"
python -m alembic upgrade head
```

### Translation Service

```powershell
cd TranslationService
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -e ".[dev]"
python -m pytest -q
python -m uvicorn app.main:app --reload --port 8001
```

The `/translate` endpoint requires Azure Translator configuration. Translation
publication additionally requires write access to the configured R2 bucket.

### Frontend

```powershell
cd FrontendApp
npm ci
npm test -- --watch=false
npm run build:localized
npm start
```

The localized preview runs at `http://localhost:4300`, with French at `/fr/`
and German at `/de/`. The current frontend is configured to call the deployed
Asset Management API.

## Cloud configuration

GitHub Actions uses repository **variables** for non-sensitive configuration:

- `AZURE_TRANSLATOR_ENDPOINT`
- `AZURE_TRANSLATOR_REGION`
- `R2_ENDPOINT`
- `R2_BUCKET`
- `R2_TRANSLATION_PREFIX`
- `TRANSLATION_VERSION`
- Optional monitoring overrides: `FRONTEND_URL` and `ASSET_API_URL`

It uses repository **secrets** for credentials:

- `AZURE_TRANSLATOR_KEY`
- `R2_ACCESS_KEY_ID` and `R2_SECRET_ACCESS_KEY` for read-only consumers
- `TRANSLATION_R2_ACCESS_KEY_ID` and `TRANSLATION_R2_SECRET_ACCESS_KEY` for publication
- `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` for Pages deployment

Consumer workflows should receive read-only R2 credentials. Only translation
publication should receive write-enabled credentials. Terraform backend keys
are kept outside GitHub Actions and scoped only to the private state bucket.

## Terraform workflow

Cloudflare definitions live in `infrastructure/cloudflare`. They manage the
existing Pages project and translation bucket with `prevent_destroy` enabled.
Terraform state lives in a separate private R2 bucket through the S3-compatible
backend.

```powershell
cd infrastructure\cloudflare
terraform fmt -check -recursive
terraform init
terraform validate
terraform state list
terraform plan
```

Existing Cloudflare resources must be imported into an empty state before the
first plan; they must never be imported twice. Terraform apply is deliberately
manual so every infrastructure change has a reviewed plan. See the
[Cloudflare infrastructure guide](infrastructure/cloudflare/README.md) for the
credential-loading, state-migration, and adoption procedure.

## Repository layout

```text
.
├── .github/workflows/            # CI, CD, security, release, IaC, monitoring
├── AssetManagementService/       # FastAPI CRUD API, database, reports, tests
├── FrontendApp/                  # Angular app, XLIFF catalogs, nginx image
├── TranslationService/           # Azure translation and R2 publication
├── infrastructure/cloudflare/   # Terraform resources and remote backend
├── docs/screenshots/             # Sanitized project evidence used here
└── Recommendations/              # Supporting zero-cost architecture notes
```

## Security model

- **Gitleaks** scans complete Git history for accidental credentials.
- **CodeQL** analyzes security-sensitive data flow in Python and TypeScript.
- **Trivy** blocks high or critical known dependency and image vulnerabilities
  and inspects Docker and Terraform configuration.
- Application containers run as non-root users.
- Translation read and write permissions are split across separate R2 keys.
- Terraform state is private, remote, and never committed to the repository.
- Deployment consumes tested artifacts and enforces branch-to-environment rules.

## Current scope and next steps

This is a working portfolio POC rather than a production tenancy. Its current
focus is a clear, reproducible, low-cost architecture. The next production
steps would be API authentication and authorization, a managed persistent
database, centralized logs and alert routing, state locking, environment
promotion with protected approvals, and automated rollback policies.
