#!/bin/bash
# Backfill GitHub Releases for thalian-ai/thalian
# Run this once after pushing the repo.
# Requires: gh CLI authenticated with thalian-ai org access

set -e

REPO="thalian-ai/thalian"

echo "Creating historical releases for $REPO..."

gh release create v2026.01 \
  --repo "$REPO" \
  --title "January 2026 — Platform Launch" \
  --notes "## January 2026

### Launch

- **Thalian platform launch** with support for 15 initial integrations
- **79 analysis rules** across 7 categories: Identity Security, Shadow IT, Compound Risk, Device Posture, License Waste, Drift Signal, Access Hygiene
- **25 remediation action types** across identity, application, and device categories
- **6 RBAC roles** with enforced permission hierarchy
- **AES-256-GCM encryption** for all integration credentials
- **Immutable audit log** with SHA-256 integrity hashing
- **Free, Pro, and Enterprise plans** with 30-day Pro trial for new workspaces"

gh release create v2026.02 \
  --repo "$REPO" \
  --title "February 2026" \
  --notes "## February 2026

### New Features

- **AI Brief** — AI-generated natural language summary of your workspace's security posture, available on the Dashboard and Reports pages
- **Remediation approval workflow** — Agent-initiated actions on high/critical findings require Security Analyst approval
- **Sync events log** — View all data changes (created, updated, deleted) detected during integration syncs

### Integrations

- Added **SentinelOne** — Agents, threats, and device health
- Added **Hexnode** — Cross-platform devices and policies
- Added **Jira Service Management** — Service requests, agents, and queues

### Improvements

- **MFA enforcement** — Workspace admins can now require TOTP-based MFA for all members
- **MTTR tracking** — Mean Time to Remediate metrics by severity, with trend charts"

gh release create v2026.03 \
  --repo "$REPO" \
  --title "March 2026" \
  --notes "## March 2026

### New Features

- **SAML 2.0 SSO** (Enterprise) — Configure single sign-on from Settings → Security → SSO/SAML
- **Security Posture score** — Unified 0–100 score with sigmoid normalization and letter grade (A–F)
- **AI-reasoned remediation** — Claude analyzes all open risks for an entity and proposes a sequenced action plan
- **Public status page** — Real-time platform health at status.thalian.ai
- **Impact Analysis page** — Model remediation scenarios before executing them
- **KPI Dashboard and Goals Tracker** — Set measurable security goals across 14 metrics
- **Access review campaigns** — Structured user access certification with ITSM integration and CSV export
- **Claude-driven agentic remediation planner** — Automatic post-sync analysis and action queuing
- **AWS IAM integration** — Detect IAM users outside your corporate IDP lifecycle controls
- **GCP IAM integration** — Detect IAM access gaps across GCP projects
- **Behavioral anomaly detection** — Per-user baseline anomaly rules for login patterns and access changes
- **7 cross-platform compound rules** — Findings requiring 3+ data sources to fire
- **Shadow admin detection** — Users who are standard in the IDP but hold admin roles in 3+ SaaS apps
- **SSO coverage per identity** — Per-user SSO vs. direct-auth breakdown with 7 new detection rules
- **Drift velocity projection** — Forward projection on posture sparklines via linear regression
- **\"Since your last session\" AI brief** — Personalized dashboard brief showing what changed since last login

### Integrations

- Added **AWS IAM**, **GCP IAM**, **Salesforce**, **Workday HR**
- Added **Cisco Meraki**, **Confluence**, **SharePoint**, **Freshservice**, **Zendesk**
- 31 platforms now supported across 7 categories

### Improvements

- **Hourly auto-sync** — Connected integrations now sync every hour (previously every 6 hours)
- **Okta: OAuth 2.0 client credentials** — Replaced static API tokens with OAuth client credentials
- **Slack alerts: Dismiss and Snooze** — Action buttons directly on Slack alert cards
- **Performance** — Initial app bundle reduced by 69%; database queries parallelized"

gh release create v2026.04 \
  --repo "$REPO" \
  --title "April 2026" \
  --latest \
  --notes "## April 2026

### Security

- **npm supply chain hardening** — Audited all dependencies following the March 30 Axios supply chain incident (CVE pending). Thalian is not affected — axios is not in our dependency tree. Build pipeline hardened: npm audit blocks on high-severity findings, postinstall scripts from transitive dependencies disabled, all versions pinned exactly, lockfile integrity validation added to CI.

### New Features

- **Entra ID: Conditional Access policy detection** — Thalian now fetches and analyzes your Entra ID Conditional Access policies after each sync. Three new rules: MFA policy in report-only mode, disabled MFA policy, and admin accounts excluded from all MFA-requiring CA policies. AI assistant gains a Conditional Access context block.

- **Okta System Log correlation** — Three new rules using System Log data: failed MFA spike (potential credential stuffing), MFA factor disabled, and user-reported compromise (\"This wasn't me\" clicked — highest-confidence account takeover indicator).

### Improvements

- **GCP IAM privilege analysis** — 4 new privilege rules: owner role sprawl, service accounts with admin roles, users with admin access across 3+ projects, systemic over-provisioning (>50% at Editor or higher)."

echo ""
echo "Done. All releases created at https://github.com/$REPO/releases"
