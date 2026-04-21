# Changelog

Notable changes, new features, and fixes for the Thalian platform.

---

## April 2026

### Integrations

- **Datadog** — Connect Datadog with an API Key + Application Key. Thalian syncs users and role assignments to detect Datadog admins with no corporate identity (critical), admin accounts without MFA (when no SSO is in use), standard users outside IDP lifecycle controls, and offboarded employees who retain full infrastructure visibility. 4 detection rules.

- **Zoom** — Connect your Zoom organization to detect users and admins not in your corporate IDP, SSO enforcement gaps, offboarded employees with active Zoom accounts, and stale unused seats. 5 detection rules.

- **Box** — Connect Box to detect IDP gaps, offboarded employees retaining file access, and external sharing activity. Cross-references with IDP data to surface departed employees who still have access to corporate files. 4 detection rules.

- **GitLab** — Connect a GitLab group via Group Access Token for developer access intelligence. Syncs members, projects, deploy keys, and group tokens. Works with GitLab.com and self-hosted. 8 detection rules including Maintainer/Owner not in IDP (critical), MFA gaps, external member access, write deploy keys, non-expiring group tokens, offboarding gaps, and stale members.

- **GitHub secret scanning** — 2 new rules using GitHub Advanced Security data: unresolved secret scanning alerts (critical) and repeated push protection bypasses (high).

- **CrowdStrike Spotlight** — 2 new rules: unpatched critical/high CVEs on managed devices, and high-severity vulnerabilities on admin-access devices.

- **Entra PIM activation monitoring** — 2 new rules: PIM role activated without justification, and PIM activation outside business hours.

- **Okta high-risk signin** — 1 new rule fires on completed sign-ins flagged as high risk by Okta's risk engine.

- **Box Shield + departing employee downloads** — 2 new rules: unresolved Box Shield threat alerts, and mass file downloads by offboarded employees.

- **Salesforce permission set escalation** — 2 new rules: admin-equivalent permission set assignment for non-admin users, and active session-based permission escalation.

- **SentinelOne Ranger** — 1 new rule: unmanaged network devices discovered by Ranger that lack a SentinelOne agent.

- **Confluence + Jira audit rules** — 2 new rules: space permission changes in Confluence and permission scheme changes in Jira.

### New Features

- **Cross-platform brute-force detection** — Detects credential stuffing attacks by correlating failed login events across identity providers and SaaS apps. Fires when multiple IPs attempt repeated failed logins against the same account. Escalates when the same email shows failures on both the IDP and downstream SaaS platforms — a coordinated attack no single tool can see.

- **341 detection rules** — The analysis engine now runs 341 rules (up from 173 in mid-March), covering identity security, access hygiene, device posture, behavioral anomalies, shadow IT, license waste, compound cross-platform risks, and drift signals.

- **Cross-platform compound rules** — 14 new rules that require data from 3+ connected platforms to fire — findings that no single tool can surface.

- **AWS IAM deep analysis** — Credential Report, root MFA status, CloudTrail root activity, IAM role trust policy analysis. 11 AWS rules total.

- **GCP service account key monitoring** — Detects unrotated user-managed keys and Workload Identity adoption gaps.

- **Salesforce session and export detection** — Profile permission analysis, session IP restrictions, and bulk data export event detection. 9 Salesforce rules total.

- **Entra ID Identity Protection and PIM** — Risky users, PIM permanent role assignments, admin MFA method analysis, guest invitation policies. 6 new rules.

- **Okta security configuration analysis** — ThreatInsight, MFA enrollment policies, password policies, API token hygiene, session settings. 14 Okta rules.

- **AI context for all platform metadata** — The AI assistant now surfaces detailed security configuration data from all connected platforms.

- **Access review bulk decisions + overdue reminders** — Bulk approve/revoke in access review campaigns. Overdue reminder emails sent automatically to reviewers.

- **Trial extension + compliance preview** — Free-tier users can self-serve a trial extension. Compliance page visible in preview mode for free users.

- **Security Posture Timeline** — New History page (**Reports → Timeline** or the dashboard "Monitoring since" badge) shows posture score over time, MFA coverage trend, compliance rate, and a narrative event log of grade shifts, MFA drops, new integrations, and remediation milestones.

- **Integration Coverage Widget** — Dashboard now shows a 6-category coverage bar (Identity, Endpoint, HR, Security, Cloud, Comms) with per-category status dots and a CTA for the highest-priority gap.

- **MCP server + API Keys** — Query your Thalian workspace from Claude Code using the Model Context Protocol. Generate an API key in **Settings → API Keys** and use six available tools: `get_risk_score`, `list_findings`, `lookup_identity`, `get_integrations`, `get_posture_summary`, and `trigger_sync`. API keys are workspace-scoped and read-only.

- **Remediation playbooks** — Multi-step automated response sequences on the Policies page. Build ordered playbooks (e.g., "Offboard terminated employee") that run across platforms with per-step auto-execute or approval controls. Available on Pro and Enterprise.

- **PDF evidence export for access reviews** — Access review campaigns now include a PDF export of reviewer decisions, timestamps, and entity details for audit documentation.

- **Compliance Trend tab** — New trend view on the Compliance page showing control pass rate over time, rule coverage, and open finding counts by framework.

- **In-app service status banner** — Dismissible banner appears during active incidents or service degradations.

- **Free plan identity usage bar** — Free plan workspaces now see a live usage bar showing monitored identities vs. the plan limit, with a clear upgrade path.

- **390 detection rules** — +40 new platform-depth rules for Intune, Jamf, Fleet, Workspace ONE, Iru, Workday, Microsoft 365 (Teams/SharePoint/Outlook), JumpCloud, and OneLogin. Highlights: non-compliant Intune admin with SaaS access, Fleet CVE + sensitive-app owner, Workday contingent worker with permanent-employee access, Teams offboarded user still a guest, SharePoint anonymous link policy open, Outlook external mailbox delegation, MDM × IDP compound rules (unmanaged device with IDP SSO access, terminated device still enrolled, BYOD owner with admin entitlements), JumpCloud/OneLogin MFA and policy coverage gaps. No new integrations required — all rules fire on existing synced data.

### Improvements

- **Workspace risk score rebuilt** — Linear, CVSS-aligned formula replaces sigmoid curve that saturated at high risk levels and caused all Recommended Actions point deltas to show ±0. Each finding now produces a proportional, non-zero score movement. Cost-only findings (license waste) and metadata-noise rules excluded from the workspace score. Six rules reclassified from low to medium: Okta factor enrollment optional, Okta network zone bypass, Okta ThreatInsight disabled, Entra Security Defaults disabled, GitHub default branch protection missing, SharePoint external sharing activity.

- **Webhook destination picker** — Two-section picker (Workflow Automation: Workato, Zapier, n8n, Gumloop, Make; SIEM & Observability: Datadog, Splunk, Elastic, Panther, Sumo Logic) with per-destination setup hints
- **Webhook event improvements** — `finding_detected` now fires only for new findings (not all open findings every run); new `finding_resolved` event when a condition clears; `analysis_completed` gains `new_findings_count`; `finding_detected` payload enriched with `finding_id`, `action_type`, `source_integrations`
- **Remediation action buttons** across all finding types
- **Application sanctions** directly from the Applications page
- **Finding deduplication** — actioned findings no longer re-created on next analysis
- **GCP IAM role names in findings** — findings now display specific role names (Owner, Editor, Viewer)
- **Analysis cooldown reduced** from 5 minutes to 1 minute
- **Sidebar findings count** updates immediately after analysis
- **Analysis error reporting** — insert errors now reported to Sentry and audit log
- **Landing page overhaul** — OG image for social sharing, "See Live Demo" CTA, rendered FAQ section, mobile nav fix, Docs link in top nav
- **Demo experience** — Guided 5-step walkthrough, demo banner with conversion CTA, streamlined login with request access form
- **Signup hardening** — Company name required, personal email domains blocked
- **SSO error messaging** — Admin self-service guidance when no SSO configured
- **Iru naming** — Kandji references updated to "Iru (formerly Kandji)"
- **FAIR-aligned entity risk scoring** — Entity risk scores now use a FAIR-aligned model for more meaningful, comparable scores across identity types
- **Integration error classification** — Errors classified by type (auth expired, config invalid, rate limited). Sidebar badge and app-wide banner for critical errors
- **Blast radius orbit visualization** — Interactive orbit diagram replaces flat list on entity detail blast radius view
- **Behavioral baseline accuracy** — Directory login events excluded from baselines when a dedicated IDP is connected
- **Finding category consolidation** — "Configuration" category folded into "Access Risk" and "Identity Security"
- **Free plan identity usage bar** — Live usage bar showing monitored identities vs. plan limit with upgrade path
- **Pro data retention** — Extended from 90 days to 1 year for all workspace data and audit logs

### Fixes

- **SSO finding accuracy for Google Workspace-only environments** — SSO findings now correctly surface ungoverned OAuth grants (not "SSO bypass") when Google Workspace is the only IDP. Titles, descriptions, and remediation guidance updated.
- **SSO finding accuracy — Google-only ratio and payload corrections** — Follow-up: `sso::high_direct_auth_ratio` now requires a majority threshold before firing; entity payloads for Google-only paths corrected to report `oauth_count` instead of `direct_count: 0`.
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
- Fixed billable identity count inflated by SaaS-only accounts — now IDP/directory users only
- Fixed MTTR calculations including auto-resolved findings
- Fixed device page managed/unmanaged tab split — now a single unified view
- Fixed behavioral baseline suppression scope applying too broadly
- Downgraded `suspicious_programmatic_login` from high to medium severity
- Fixed Google OAuth WebViews warning
- Fixed billing flow — plan gate incorrectly blocking some Pro actions
- Fixed approval request emails double-sending

### Security

- **npm supply chain hardening** — In response to the March 30 Axios npm supply chain attack (CVE pending, attributed to North Korean threat actor UNC1069), we audited all dependencies and confirmed Thalian is not affected — axios is not in our dependency tree. We've additionally hardened our build pipeline: npm audit now blocks deployments on high-severity findings, postinstall scripts from transitive dependencies are disabled by default, all dependency versions are pinned exactly, and lockfile integrity validation has been added to CI.

- **AI chat prompt injection hardening** — Topic-scoping guardrails added to the AI assistant to prevent prompt injection and constrain responses to IT security topics.

- **RBAC audit** — Closed role gating gaps across integration management, workspace settings, billing actions, and agentic remediation approvals. No data was exposed.

- **Workspace ONE vendor reference** — Updated references from "VMware Workspace ONE" to "Omnissa Workspace ONE" following the acquisition and rebrand.

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
