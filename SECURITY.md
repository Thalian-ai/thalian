# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in the Thalian platform, please report it responsibly.

**Email:** security@thalian.ai

Please include:
- A description of the vulnerability and its potential impact
- Steps to reproduce or a proof of concept
- Any relevant screenshots or logs (redact sensitive data)

**Do not** open a public GitHub issue for security vulnerabilities.

## Response Timeline

| Stage | Target |
|-------|--------|
| Initial acknowledgment | Within 48 hours |
| Triage and severity assessment | Within 5 business days |
| Fix timeline communicated | Within 10 business days |
| Resolution and disclosure | Coordinated with reporter |

## Scope

### In scope
- `app.thalian.ai` — the production application
- `api.thalian.ai` / Cloudflare Pages Functions — backend API endpoints
- Authentication and authorization logic
- Integration credential handling and encryption
- Data isolation between workspaces (multi-tenancy)

### Out of scope
- Social engineering attacks
- Physical attacks
- Denial of service attacks
- Vulnerabilities in third-party services (Supabase, Cloudflare, Stripe, etc.) — report those to the respective vendors

## Security Architecture

- All integration credentials are encrypted at rest using AES-256-GCM
- Row-level security (RLS) enforced at the database layer — all queries are workspace-scoped
- Immutable audit log with SHA-256 integrity hashing
- Zero plaintext credentials stored or logged

## Acknowledgments

We appreciate security researchers who help keep Thalian and our users safe. Responsible disclosures will be acknowledged in our release notes (with your permission).
