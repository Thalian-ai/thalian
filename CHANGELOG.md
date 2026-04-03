# Changelog

Notable changes, new features, and fixes for the Thalian platform.

---

## April 2026

### Integrations

- **Zoom** — Connect your Zoom organization to detect users and admins not in your corporate IDP, SSO enforcement gaps, offboarded employees with active Zoom accounts, and stale unused seats. 5 detection rules.

- **Box** — Connect Box to detect IDP gaps, offboarded employees retaining file access, and external sharing activity. Cross-references with IDP data to surface departed employees who still have access to corporate files. 4 detection rules.

### New Features

- **316 detection rules** — The analysis engine now runs 316 rules (up from 173 in mid-March), covering identity security, access hygiene, device posture, behavioral anomalies, shadow IT, license waste, compound cross-platform risks, and drift signals.

- **Cross-platform compound rules** — 14 new rules that require data from 3+ connected platforms to fire — findings that no single tool can surface.

- **AWS IAM deep analysis** — Credential Report, root MFA status, CloudTrail root activity, IAM role trust policy analysis. 11 AWS rules total.

- **GCP service account key monitoring** — Detects unrotated user-managed keys and Workload Identity adoption gaps.

- **Salesforce session and export detection** — Profile permission analysis, session IP restrictions, and bulk data export event detection. 9 Salesforce rules total.

- **Entra ID Identity Protection and PIM** — Risky users, PIM permanent role assignments, admin MFA method analysis, guest invitation policies. 6 new rules.

- **Okta security configuration analysis** — ThreatInsight, MFA enrollment policies, password policies, API token hygiene, session settings. 14 Okta rules.

- **AI context for all platform metadata** — The AI assistant now surfaces detailed security configuration data from all connected platforms.

### Improvements

- **Remediation action buttons** across all finding types
- **Application sanctions** directly from the Applications page
- **Finding deduplication** — actioned findings no longer re-created on next analysis
- **GCP IAM role names in findings** — findings now display specific role names (Owner, Editor, Viewer)
- **Analysis cooldown reduced** from 5 minutes to 1 minute
- **Sidebar findings count** updates immediately after analysis
- **Analysis error reporting** — insert errors now reported to Sentry and audit log

### Fixes

- Findings suppression after remediation
- Remediation denied actions no longer resurface
- Reports sparkline accuracy
- Integration removal cleanup and PII anonymization
- Light mode readability improvements
- Fixed integration removal failing with internal error
- Fixed GCP IAM sync not discovering projects (v1 API fallback)
- Fixed GCP IAM identities not syncing (identity_type constraint)
- Fixed analysis dropping findings on duplicate finding_key batch insert
- Fixed native client apps (iOS Mail, Android) flagged as shadow IT
- Fixed ghost identities appearing after integration removal
- Fixed compound finding "Related findings" links pointing to stale IDs
- Fixed orphaned entities after integration removal (FK changed to CASCADE)
- Fixed GCP IAM remediation buttons showing app actions instead of identity actions

### Security

- **npm supply chain hardening** — In response to the March 30 Axios npm supply chain attack (CVE pending, attributed to North Korean threat actor UNC1069), we audited all dependencies and confirmed Thalian is not affected — axios is not in our dependency tree. We've additionally hardened our build pipeline: npm audit now blocks deployments on high-severity findings, postinstall scripts from transitive dependencies are disabled by default, all dependency versions are pinned exactly, and lockfile integrity validation has been added to CI.

---

## March 31, 2026

### New Features

- **Entra ID: Conditional Access policy detection** — Thalian now fetches and analyzes your Entra ID Conditional Access policies automatically after each sync (requires re-authorizing the Microsoft connection to grant `Policy.Read.All`). Three new detection rules fire when CA policies are available: MFA policy in report-only mode (logs violations but never blocks), disabled MFA policy (potential regression if previously enforced), and admin accounts explicitly excluded from all MFA-requiring CA policies. The AI assistant also gains a Conditional Access context block and can answer questions about which policies are enforced vs report-only, whether MFA is actually blocking sign-ins, and which admins aren't covered. Existing Entra connections without the new scope continue working — CA rules stay silent until re-auth.

- **Okta System Log correlation** — Three new Okta-specific detection rules now use System Log data to surface credential and authentication risks that event-by-event inspection misses: failed MFA spike (5+ failed MFA challenges per user in the sync window — potential credential stuffing), MFA factor disabled (user or admin disabled an MFA factor — elevated severity for admin accounts), and user-reported compromise (user clicked "This wasn't me" in Okta — highest-confidence indicator of active account takeover). Okta System Log has been synced since launch; these rules make that data actionable without any new connection steps.

### Improvements

- **GCP IAM privilege analysis** — GCP IAM now detects 4 new privilege and configuration risks beyond IDP gap detection: owner role sprawl per project, service accounts with admin-level roles, users with admin access across 3+ projects, and systemic over-provisioning (>50% of users at Editor or higher). These rules fire even when Google Workspace is the IDP — previously, GCP findings only appeared when users existed outside the corporate identity provider.

---

## March 30, 2026

### Integrations

- **Workday HR** — Connect Workday to cross-reference employee lifecycle data against your identity providers and SaaS access. Thalian syncs active and terminated workers from Workday and detects terminated employees who still have active IDP accounts, SaaS entitlements, or managed devices. Joins with Okta, Entra ID, Google Workspace, JumpCloud, OneLogin, Intune, Jamf, and all connected SaaS platforms. Read-only — uses Workday's REST API with basic auth credentials. Adds to the existing HR intelligence layer alongside Rippling and BambooHR.

### New Features

- **Compliance: evidence export (Enterprise)** — The Compliance page now includes PDF and Excel evidence pack export for Enterprise workspaces. Pro users see a locked "Export evidence" button with an upgrade prompt. The export includes control status, mapped rules, open findings, and a timestamp — formatted for handing directly to an auditor.

- **Compliance: audit log tab** — A dedicated Audit Log tab is now available on the Compliance page, showing a filterable, searchable feed of all user and system actions. Pro workspaces see 30-day history with CSV export; Enterprise sees 1-year retention. Free users see the plan gate.

- **Integration library redesign** — The integration browser has a new card layout and filter bar. Cards now show category, connection status, and sync stats. Filter by category (Identity, Device, HR, Cloud, etc.) to find what you need faster.

- **Clickable stat pills on integrations** — Stat pills on connected integration cards (e.g. "42 identities", "7 findings") now navigate directly to the relevant filtered view — Identities, Applications, Devices, or Findings — scoped to that integration.

### Improvements

- **Plan tier copy** — The billing and upgrade pages now accurately reflect what each plan includes.

### Fixes

- **Display labels throughout** — Raw internal identifiers (e.g. `notify_user`, `google_workspace`, `non_compliant`, `in_progress`) no longer appear in the UI. Action types, remediation statuses, compliance statuses, and audit event types are now shown as readable labels everywhere.
- **Audit log retention** — The audit log now correctly shows 90-day history for Pro workspaces (previously displayed "30-day history" due to a hardcoded mismatch).
- **Compliance deep links** — "View findings →" links inside expanded compliance controls now navigate correctly to the Findings page filtered to that rule.
- **AI chat MFA/login accuracy** — The AI assistant no longer reports MFA or login status for platforms that don't expose that data (e.g. GitHub, Slack), preventing misleading "no MFA" statements for accounts where MFA is managed by an IDP.

---

## March 29, 2026

### Integrations

- **Salesforce** — Connect Salesforce to detect CRM access gaps between your Salesforce org and your corporate identity provider. Thalian syncs all active and inactive Salesforce users and cross-references against Okta, Entra ID, Google Workspace, JumpCloud, and OneLogin. Fires four new findings: Salesforce admin not in IDP (critical), Salesforce user not in IDP (high), stale Salesforce user whose IDP account is suspended or deprovisioned but CRM access remains active (high), and connected app authorized by an unknown user outside the IDP (medium). Read-only — no write permissions requested.

### Improvements

- **Slack alerts: Dismiss and Snooze from Slack** — Security alerts sent to Slack now include Dismiss and Snooze 7d buttons directly on every alert card. Both actions update the original Slack message in place with a confirmation line. All actions are signature-verified and written to the immutable audit log.

- **Okta: upgraded to OAuth 2.0 client credentials** — Okta sync now authenticates using OAuth client credentials instead of a static SSWS API token. More secure, token rotation is handled automatically.

---

## March 28, 2026

### Integrations

- **AWS IAM** — Connect AWS Identity and Access Management to detect IAM users that exist outside your corporate IDP lifecycle controls. Detects admin-level accounts with no matching IDP identity, IAM users without MFA enrolled, and stale IAM users whose IDP account has been suspended or deprovisioned.

- **GCP IAM** — Connect Google Cloud Platform to detect IAM access gaps between your GCP projects and your corporate identity provider. Fires four findings: GCP project owner not in IDP (critical), GCP member not in IDP (high), public IAM binding via `allUsers` or `allAuthenticatedUsers` (critical), and stale IAM binding for a suspended or deprovisioned user (high).

### New Features

- **Access review campaigns** — Run structured user access certification campaigns directly in Thalian. Scope by department or application, work through entitlements — approving, revoking, or granting time-limited exceptions. Revoke decisions automatically open an ITSM ticket. Completed campaigns export to CSV as audit evidence for SOC 2 (CC6.3), ISO 27001, and HIPAA reviews.

- **Claude-driven agentic remediation planner** — After every sync, Claude Sonnet reviews all new findings and decides which ones need action. Queued actions now include a "Claude's reasoning" block explaining the recommendation and why the sequencing is correct.

---

## March 26, 2026

### New Features

- **"Since your last session" AI brief** — The dashboard AI brief now opens with what changed since you last logged in — personalized context on every login.
- **Cross-platform perspective view on findings** — Expanding a cross-platform finding shows a side-by-side breakdown of what each connected platform sees vs. what Thalian sees by joining them.
- **Live cost counter on integration discovery** — Connecting a new integration that reveals license waste animates the cost counting up as findings are scored.
- **Drift velocity projection** — Posture sparklines now show a dashed forward projection via linear regression, with projected breach dates for declining metrics.
- **AI chat contextual actions** — When the AI mentions a high-severity finding, it surfaces the available remediation action: "You can suspend her in Okta directly from here if needed."
- **Behavioral anomaly detection** — Rules detect unusual login patterns, off-hours spikes, and sudden app access changes vs. per-user baselines.
- **7 new cross-platform compound rules** — Findings requiring 3+ connected data sources: terminated employee with dual exfiltration paths, admin on compromised device with active EDR threat, coordinated multi-platform admin actions within 30 minutes, and more.
- **Shadow admin detection** — Identifies users who are standard users in the IDP but hold admin roles in 3+ SaaS apps — the privilege gap no single tool can see.
- **Benchmark SaaS pricing** — License waste findings estimate cost impact using per-user pricing for 40+ SaaS apps, without requiring contract uploads.

### Improvements

- **Hourly auto-sync** — Connected integrations now sync every hour (previously every 6 hours).
- **Findings page streamlined** — Value badges consolidated, sort controls merged, layout tightened.

---

## March 25, 2026

### New Features

- **SSO coverage per identity** — The Identities page now shows how many of each user's apps are SSO-managed vs. direct-auth, with 7 new detection rules for SSO gaps (admin with direct-auth apps, executive bypassing SSO, offboarded user with unreachable direct-auth apps, and more).
- **3 new drift signal rules** — SSO coverage declining, termination-to-access-removal lag growing, and ghost identity growth — all requiring 3+ data sources to fire.
- **Automatic remediation after every sync** — Safe actions execute immediately; risky actions queue for admin approval and trigger an email notification.
- **AI Risk Summary on identity detail** — Opening an identity with findings shows a Claude-generated narrative covering risk score, MFA, app access breadth, device compliance, and blast radius.

---

## March 23, 2026

### Improvements

- **In-app support form** — "Contact support" now opens a proper support form with ticket confirmation email, instead of a chat widget.

---

## March 20, 2026

### New Features

- **SAML 2.0 SSO (Enterprise)** — Configure SAML 2.0 single sign-on from Settings → Security → SSO/SAML. Supports SP-initiated and IdP-initiated login. Works with Okta, Azure AD, and any SAML-compatible IdP. SSO users are auto-provisioned on first sign-in.
- **Security Posture score history and sparkline** — The Security Posture stat now shows a live sparkline and delta vs. the previous analysis run.

### Improvements

- **AI chat** — Full visibility into remediation history (last 30 days), richer entity data (named users, app categories, OS versions), what-if simulation tool, and stale access analysis.
- **Security Posture score** — Unified 0–100 score with sigmoid normalization and letter grade (A–F), replacing the raw risk score. Dashboard and AI assistant now always agree.

---

## March 19, 2026

### New Features

- **AI-reasoned remediation** — Ask Claude to analyze all open risks for an entity and propose a sequenced action plan with reasoning.
- **Public status page** — Real-time platform health at [status.thalian.ai](https://status.thalian.ai) with incident history and email subscription.
- **Layer 3 behavioral baselines** — Per-entity anomaly detection across logins, apps, locations, and failed auth.

### Improvements

- **Performance** — Initial app bundle reduced by 69%; database queries parallelized.
- **Auto-sync reliability** — Integrations now sync in parallel.

### Security

- Auth guards and workspace scoping added to 7 previously unguarded API endpoints.

---

## March 2026

### New Features

- **Impact Analysis page** — Model remediation scenarios before executing them with the scenario builder.
- **KPI Dashboard and Goals Tracker** — Set measurable security goals with target values, deadlines, and AI-recommended actions across 14 metrics.
- **Policy auto-generation** — Auto-generated security policy drafts based on connected integrations and active findings.
- **Causality Insights** — Cross-platform finding correlation that surfaces connections between related findings.
- **Agentic remediation** — Automated remediation with three tiers for Pro and Enterprise workspaces.

### Integrations

- Added **Cisco Meraki**, **Confluence**, **SharePoint**, **Freshservice**, **Zendesk**
- 24 platforms now supported across 7 categories

---

## February 2026

### New Features

- **AI Brief** — AI-generated natural language summary of workspace security posture.
- **Remediation approval workflow** — Agent-initiated actions on high/critical findings require Security Analyst approval.
- **Sync events log** — View all data changes detected during integration syncs.

### Integrations

- Added **SentinelOne**, **Hexnode**, **Jira Service Management**

### Improvements

- **MFA enforcement** — Workspace admins can now require TOTP-based MFA for all members.
- **MTTR tracking** — Mean Time to Remediate metrics by severity, with trend charts.

---

## January 2026

### Launch

- **Thalian platform launch** with support for 15 initial integrations
- **79 analysis rules** across 7 categories
- **25 remediation action types** across identity, application, and device categories
- **6 RBAC roles** with enforced permission hierarchy
- **AES-256-GCM encryption** for all integration credentials
- **Immutable audit log** with SHA-256 integrity hashing
- **Free, Pro, and Enterprise plans** with 30-day Pro trial for new workspaces
