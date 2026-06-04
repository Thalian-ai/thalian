# Changelog

Notable changes, new features, and fixes for the Thalian platform.

---

## June 2026

### Improvements

- **Navigation consolidated to a seven-item sidebar.** The left navigation collapses from twelve entries to a seven-item spine: **Overview**, **Findings**, **Inventory**, **Remediation**, **Compliance & posture**, **Integrations**, and **Settings**. Three parent pages group what used to be separate top-level routes. **Inventory** holds **People**, **Non-human**, **Applications**, and **Devices** as tabs, with the **Non-human** tab always present -- even on a brand-new workspace it shows what it catches: service accounts, tokens, OAuth grants, bots, and AI agents. **Remediation** gains a **Simulate** tab for before/after impact analysis, and **Compliance & posture** folds access reviews, policies, posture, and reports into tabs alongside controls. Every previous URL keeps working through a redirect, and bookmarks that carry tab, filter, or framework parameters resolve to the right place, so saved deeplinks and shared links continue to work.

- **Cross-entity navigation.** Every identity, device, and application row in the inventory now carries a quick-navigate button that opens the Findings page pre-filtered to that entity's open findings. On the Applications page, the user-count chip links to the Identities page filtered to users of that application. The entity detail panel gains a **View all findings** link in the Findings section header. No manual filter setup required.

- **AI chat context pre-loading.** Opening the AI chat via a `?context_entity=` link automatically sends a context primer so the assistant is already scoped to the right identity, device, or application when you arrive. Entity detail panels and finding cards that link to chat use this parameter.

### Fixes

- **Crash on the Findings page for workspaces with AI agent findings fixed.** Navigating to `/findings` (or clicking "assign owners" from the dashboard) could hard-crash the page for any workspace where Thalian had detected AI agent or non-human identity findings. The crash was a temporal dead zone in the minified production bundle: Terser was reordering a memoized value in a way that made it inaccessible at render time. The fix replaces the direct dependency with a ref, which is immune to that reordering.

---

## May 2026

### New Features

- **Headless API (`/api/v1`).** Findings and inventory data are now readable programmatically without the web UI, so CI pipelines, scripts, and external tools can consume Thalian directly. A new versioned `/api/v1` surface accepts the same `thal_*` API keys as the MCP endpoints and returns a stable, curated field subset per collection. `GET /api/v1/findings` returns open findings filterable by status and severity with offset pagination; `GET /api/v1/inventory` returns identities, applications, or devices, each with a versioned field set that omits raw upstream payloads and internal sync columns. Every request is scoped to the workspace its key belongs to, with no override parameter, so a key can never read another workspace's data. Read-scope keys (the default) may call these endpoints. See [API Reference](https://docs.thalian.ai/api-reference) for the full field list and query parameters.

- **Write-scope API keys and `POST /api/v1/scan`.** API keys can now be minted with a `write` scope alongside the default `read`. A write key unlocks action endpoints on the headless surface, starting with `POST /api/v1/scan`, which triggers a fresh workspace analysis (the same run the Re-analyze button performs) so CI pipelines can refresh findings before reading them. The endpoint takes no body, derives its workspace from the key, is rate-limited to one trigger per workspace every 60 seconds, and audit-logs every trigger against the calling key. Read keys stay limited to GET and receive 403 on any action endpoint; minting a key still requires the Manage workspace permission, and the chosen scope is captured in the audit log. See [API Reference](https://docs.thalian.ai/api-reference) for details.

- **MCP gateway detection.** Thalian now detects OAuth-connected MCP gateway applications — Composio, Arcade, Pipedream MCP, Klavis, and similar broker platforms that act as a single OAuth grant covering dozens of downstream tool integrations. A behavioral fingerprinting engine scores each app across six signals (name/homepage match against known gateways, scope breadth across data categories, multi-tool reach, unverified publisher, grant burst) to classify it as an MCP server at a score of 70 or above. Two new findings surface the risk: **Unsanctioned MCP gateway application** (high, critical at 5+ apps) fires when an unsanctioned MCP gateway OAuth app is present; **MCP gateway with broad agentic scope** (high) fires when a gateway holds scopes spanning 4+ distinct data categories. MCP gateway apps are excluded from existing shadow IT findings to avoid double-counting. Both map to SOC 2 CC6.1/CC6.3, NIST CSF 2.0 ID.AM-05/PR.AA-05, and ISO 42001 A.10.3/A.6.2.2.

- **Device-side AI agent detection (MDM software inventory).** AI tool detection now extends from the OAuth surface into MDM-managed device inventory. Sync handlers for **Fleet**, **Jamf Pro**, **Iru** (formerly Kandji), and **Microsoft Intune** pull per-device installed software and classify each app against a closed catalog of 30+ AI tools (Cursor, Claude desktop, ChatGPT desktop, Windsurf, Continue, Cody, GitHub Copilot, Codeium, Perplexity, Devin, Ollama, LM Studio, and more). Classified installs drive the new device-side base rule **AI tool installed on managed device** plus three cross-platform compound rules that join device + identity + OAuth surfaces. **AI tool on device with no corporate OAuth grant** (medium) fires when an AI tool is installed on a device whose owner has no matching OAuth grant in any connected SaaS — the personal-account-on-corporate-device pattern, vendor cloud egress with no DLP. **AI tool footprint: device + corporate OAuth** (informational) is the happy-path enrichment finding for governed AI usage, excluded from workspace risk score. **Local LLM on privileged user device** (high) fires when Ollama or LM Studio runs on a device whose owner has admin access in any IDP — catastrophic blast radius combining vendor-cloud egress with elevated identity. Maps to SOC 2 **CC6.1** and **CC9.1**, NIST CSF 2.0 **PR.AA-01**, **PR.AA-05**, and **ID.AM-01**, and ISO 42001 **A.4.2**, **A.7.3**, and **A.9.2**. Intune customers see a one-time **Software inventory** scope warning until they reconnect to grant `DeviceManagementApps.Read.All`; Fleet, Jamf, and Iru need no re-consent. Reconnects are audit-logged as `integration_scope_extended` for SOC 2 CC8.1 attribution.

- **AI tool detection for Microsoft Entra/M365 OAuth grants.** Thalian's AI-tool findings now fire on Microsoft Graph delegated scopes (`Mail.*`, `Files.*`, `Sites.*`, `Calendars.*`, `Contacts.*`) alongside Google OAuth scopes. The Entra ID sync pulls `oauth2PermissionGrants` and matches Microsoft enterprise apps against the same AI tool catalog used for Google Workspace (Claude, ChatGPT, Cursor, Gumloop, Microsoft Copilot, Perplexity, n8n, Zapier, and others). No re-authorization required, the existing `Directory.Read.All` scope already covers it. Microsoft-shop workspaces start surfacing AI tool findings on the next sync. Rule IDs and SOC 2 / ISO 27001 / NIST CSF 2.0 / ISO 42001 mappings unchanged.

- **Link emails across platforms.** Mark one identity as also being another email address (for example, a corporate Google Workspace user who is also the personal Gmail admin on Anthropic) and Thalian merges them into a single canonical identity. Cross-platform findings ("admin in Google Workspace AND admin on Anthropic billing") now surface as one connected risk instead of two unrelated ones. The action lives in the identity detail panel under **Linked emails**, requires the `initiate_remediation` permission, is audit-logged as `identity_aliased` for SOC 2 evidence, and rejects any alias already claimed by another identity. The AI chat assistant also receives the linkage so questions about either email return the merged view.

- **AI Agent and non-human identity (NHI) governance**. Okta AI Agents are now synced as a first-class identity tier, separate from humans and traditional service accounts. AI agents appear in the Identities page with a dedicated tab and count chip, are excluded from MFA, SSO enforcement, off-hours anomaly, and behavioral baseline rules (agents run 24/7 by design), and are excluded from plan-limit identity counts. The identity detail panel shows a purple **AI Agent** badge plus an **Agent info** section with declared OAuth scopes, client ID, grant type, and owner attribution, with an orphan warning when no human owner is recorded. Two new findings surface NHI risks: **Possible AI agent unclassified** fires when a service account matches AI framework naming patterns (LangChain, CrewAI, Gumloop, n8n, and others) but hasn't been formally classified; and **AI agent count growing** fires when active agents exceed 20% of the human workforce, a compound-risk signal for uncontrolled NHI proliferation with no offboarding lifecycle. Both findings map to SOC 2 CC6.1/CC6.2 and ISO 27001 A.5.15/A.5.18.

- **Identity classification triage surface.** Classifying an identity as a non-human principal is now a first-class workflow. Auto-detected-but-unclassified identities carry an amber **needs review** dot on the Identities page that opens the detail panel at the **Account type** section. Multi-select bulk classification overrides many identities in one pass as `user`, `service_account`, `shared_mailbox`, `group`, `bot`, or `ai_agent`, each written one row at a time through the single `identity_classified` audit path so the audit hash chain stays intact. The **AI Agents** tab reads **Triage AI Agents** with a warning count when suspected agents are unclassified. The same action is reachable from AI chat and from the MCP server's new `classify_identity` write-scope tool. Every path enforces the `initiate_remediation` permission server-side. A **Triage machine identities** access-review preset scopes a campaign to all non-human identities.

- **NIST CSF 2.0 compliance framework**. Thalian's detection rules are now mapped to NIST Cybersecurity Framework 2.0. Six controls surface on the Compliance page: **PR.AA-01** (AI agent and NHI lifecycle governance), **PR.AA-03** (authentication strength), **PR.AA-05** (access reviews covering users, services, and hardware), **ID.AM-01** (asset inventory), **ID.AM-05** (resource criticality), and **DE.CM-03** (activity monitoring). NIST CSF 2.0 appears as a third tab on the Compliance page alongside SOC 2 and ISO 27001.

- **ISO 42001 compliance framework**. Thalian now maps detection rules to ISO/IEC 42001:2023, the first international AI management system standard. Seven Annex A controls surface on the Compliance page: **A.4.2** (AI resource documentation), **A.6.2.2** (AI system requirements and specification), **A.6.2.6** (AI system operation and monitoring), **A.6.2.8** (AI system event logs), **A.7.3** (data acquired by AI), **A.9.2** (responsible use processes including offboarding lifecycle), and **A.10.3** (third-party AI suppliers). Appears as a fourth tab on the Compliance page.

- **NHI-only access review scopes**. Access review campaigns now support **Non-human identities only** and **AI agents only** scope filters, so SOC 2 CC6.3 / NIST CSF 2.0 PR.AA-05 review obligations actually cover the service accounts and agents that human-identity-focused certifications miss.

- **Workspace AI memory.** Thalian's AI now remembers context across chat sessions. Save org context, accepted risks, dismissed patterns, integration notes, and remediation preferences via the chat assistant, and Claude reads them on every future conversation, remediation plan, and causality analysis. Every save and delete is recorded in the audit log.

- **Publish policies to Confluence, SharePoint, or Box.** Approved policy playbooks now publish directly to your team's collaboration platform. Three new endpoints handle create-or-update semantics. Finding detail panels render a "Team runbook" link when a relevant policy has been published.

- **First-sync activation gate.** New workspaces now connect a second integration before findings render. The single-integration experience showed mostly empty cross-platform rules and undersold what Thalian actually does.

- **Interactive column sorting.** Identities, Devices, and Applications pages sort by any column header click. Ascending, descending, and reset states.

- **MCP server: OAuth 2.0 for the Claude.ai connector.** The MCP server at `mcp.thalian.ai` now exposes a full OAuth 2.0 surface. `client_credentials` grant for the Claude.ai connector and `authorization_code` grant with PKCE for human flows. RFC 9728 protected-resource metadata endpoint. Tokens conform to the RFC 9068 access-token JWT profile.

### Improvements

- **Interactive AI is now included on paid plans; credits meter only the autonomous lane.** AI credits have been reclassified so the metering line sits where the cost actually accrues. On **Pro**, interactive AI (chat, identity dossiers, causality analysis, remediation plans, and contract extraction) is now fully included with no metering, and your monthly credit allowance meters only the autonomous lane: agentic remediation that runs without a human in the loop. Pro includes 2,500 automation credits per month plus top-up packs when you need more. On **Free**, a single monthly pool of 300 credits covers all AI usage, interactive and automation alike. **Enterprise** stays unlimited. Your monthly allowance resets at the start of each billing period; purchased top-up packs roll over and never expire. Spend draws from the monthly allowance first, then from any purchased packs.

- **Readable labels for unrecognized OAuth apps.** OAuth applications whose name is an opaque identifier — a bare Google client ID like `407408718192.apps.googleusercontent.com` or a raw GUID — no longer surface as an unreadable string. When Thalian can't resolve a vendor name and the app's scopes grant real access, the identity detail panel now shows a scope-derived label such as **Unrecognized app (email inbox, files (read/write))**, with the raw client ID demoted to a subtitle. The label is composed entirely from the app's actual OAuth scopes, so it tells you what the grant can reach even when the vendor is unknown. Apps with a recognized vendor keep their real name, and apps whose scopes grant only basic sign-in are left as-is. The label is computed at sync time and stored on the application, so it stays consistent across the Applications page, finding detail, and AI chat.

- **Executive PDF report includes AI Governance Trajectory.** The **PDF Report** export on the **Reports** page now adds an **AI Governance Trajectory** section to the board-ready **Executive Security Posture Report**. It tracks three non-human identity signals over time — non-human identities, AI governance findings, and ungoverned or stale keys — each with its current count plus a 30-day projection derived from your drift snapshot history, so a steadily climbing population reads as `42 → 61 over 21d (▲ 45%) · ~78 in 30d`. The section appears only when your workspace has non-human identity data, and its projection matches the **AI Governance Trajectory** chart on the dashboard.

- **AI agent / NHI ownership findings now catch null-owner agents.** The cross-provider **AI agent / NHI has no accountable owner** finding now fires on non-human identities with no owner recorded at all, in addition to NHIs whose declared owner has been deprovisioned. Both surface as one grouped finding, with each affected identity annotated by whether its owner left the org or was never recorded. An unowned agent is as ungoverned as an orphaned one. Stays scoped to non-AI-provider NHIs (Okta AI Agents, Slack bots, cloud service principals); the per-provider Anthropic/OpenAI owner findings still own their populations with no double-counting. Control mappings unchanged.

- **Cataloged AI bots auto-classify as AI agents.** Slack bots whose names match Thalian's closed AI / AI Automation catalog (Claude, Cursor, Gumloop, Pipedream, Zapier, n8n, and others) now receive the **AI Agent** classification at sync time, no manual override required. Non-cataloged bots stay plain service accounts; framework-name candidates continue to surface via **Possible AI agent unclassified** for admin review. Each auto-classification is audit-logged as `identity_auto_classified` with the catalog match as justification, and the existing classification dropdown remains the way to demote a bot back to plain service account. The catalog now also covers the classic RPA vendors **UiPath**, **Automation Anywhere**, and **Blue Prism**, which share Power Automate's unattended-write risk profile, so their Slack bots auto-classify too.

- **NEW badge on recent findings.** Findings that first appeared since you last viewed the Findings page carry a teal **NEW** pill. The reference timestamp is per-user, kept in your browser's local storage and scoped to each workspace, and updates after you've spent 30 seconds on the page so a quick navigation does not reset the clock. On a first-ever visit, the badge falls back to the same reference the dashboard's *New since last sync* delta card uses (the previous analysis run's drift snapshot). Resolved and dismissed findings never carry the badge. Per-browser, not per-user across devices.

- **AI spend spike detection refined.** The spend-spike rule now scales its noise floor to your organization's daily provider spend, so trivial-dollar 2x blips (`$0.12/day` jumping to `$0.26/day` was a "2.1x spike" with `$0.14` of actual movement) no longer fire as findings. Each spike is also attributed to the specific provider workspace where it happened, rather than rolled up into one aggregate finding for the entire provider account. Severity escalates to `high` at 5x the trailing 7-day average and stays `medium` for smaller jumps. Applies to Anthropic, OpenAI, and LiteLLM. Rule IDs and SOC 2 / NIST CSF 2.0 / ISO 42001 control mappings unchanged.

- **Slack bot and app integrations surfaced as non-human identities**. Thalian now inventories every bot and app installed in your Slack workspace instead of skipping them. Each appears as a service account on the Identities page, so you can see which automations have access to your channels. A new finding flags workspaces with five or more active bot integrations that have never been reviewed. Bots whose names match known AI agent frameworks (Cursor, Gumloop, CrewAI, n8n, and others) are surfaced separately under AI governance for classification. Bot identities never count toward your plan identity limit.

- **Audit log hash chain and in-product verification**. Every audit log row now carries a per-workspace SHA-256 hash chain — each row is cryptographically linked to its predecessor so any inserted, reordered, or silently deleted row is detectable. A `verify_audit_chain` database function walks the chain and confirms integrity; results appear as a live status panel on the Compliance page audit log tab (status badge, rows verified, link breaks, hash breaks, chain tip hash, seal root). Enhances SOC 2 CC8.1, ISO 27001 A.8.15, and ISO 42001 A.6.2.8 evidence quality.

- **Audit log JSONL chain export** (Enterprise). A new **Download Chain Export** button on the Compliance page exports the full audit log as a JSONL file with chain provenance metadata embedded (`thalian-audit-export/1` schema). Includes genesis hash, chain tip hash, pre-cutover seal root, and cutover timestamp. Designed for offline verification with the public Python verifier at `tools/verify-audit-export.py`. Every export is audit-logged.

- **Compliance Trend chart plots all four frameworks**. The Compliance Trend chart now plots SOC 2, ISO 27001, NIST CSF 2.0, and ISO 42001 scores side-by-side over time. Each framework writes its own score column to `drift_snapshots` on every analysis run; historical gaps appear as line breaks until enough post-deploy snapshots accumulate.

- **MCP server, action tools (v1.1.0)**. The MCP server at `mcp.thalian.ai` now supports six new tools for write-scope API keys. Query tools: `list_rules` (all active detection rules with severity and category), `check_app_policy` (look up whether an app is sanctioned, unauthorized, or blocked). Action tools: `snooze_finding` (snooze for 1–90 days), `dismiss_finding`, `remediate_finding` (queue a remediation action for admin approval), and `set_app_policy` (sanctioned / unauthorized / blocked / clear). All action tools require a write-scope API key and are recorded in the audit log. See [MCP Server](https://docs.thalian.ai/mcp-server) for setup details.

- **AI chat grouped finding context**. The AI assistant now surfaces all affected user emails within grouped findings, enabling targeted remediation directly from chat. Previously, grouped findings (suspended users in groups, admin-without-MFA, stale admins) showed no specific identities to the assistant, it couldn't name the user or act on them.

- **`remove_admin_role` via AI chat**. New confirmation-gated action in the AI assistant for removing admin/privileged roles from a specific user across all connected IDPs (Okta, Google Workspace, Entra ID, JumpCloud, OneLogin). Account stays active; only elevated roles are removed.

- **Compliance control mapping expansion**. SOC 2, ISO 27001, NIST CSF 2.0, and ISO 42001 control mappings now cover nearly twice as many detection rules. Key additions: access review evidence rules (`access_review::overdue`, `access_review::rubber_stamped`) mapped to CC6.8; all 15 `ai_governance::*` rules mapped to ISO 42001 and NIST CSF 2.0 for the first time; terminated employee compound rules expanded across CC6.7 and A.6.5; cloud IAM privilege rules (AWS, GCP, Azure) mapped to CC6.5/CC9.1/A.8.2; audit trail gap rules added to CC8.1 and A.8.15. All 203 mapped rule IDs validated against the live rule set with zero broken references.

- **Seven more rules emit grouped findings.** Device staleness (EDR agent outdated, OS updates overdue), password policy gaps (password-never-expires, stale passwords), Slack and Azure users without IDP coverage, and executive direct-authentication bypasses previously emitted one finding per affected entity. They now emit a single grouped finding with the full affected entity list inside. Auto-resolve handles the migration on first analysis run after deploy.

- **Trend findings are drillable.** Workspace-level trend and aggregate findings now attach the underlying entities so you can act from the finding panel instead of hunting through the Identities, Devices, or Applications pages. Twelve rules updated across shadow IT, device posture, identity security, access hygiene, behavioral anomaly, license waste, and compound risk: unsanctioned app growth (apps with newly discovered ones flagged as the delta drivers), declining EDR coverage (unprotected devices), BYOD growth (unmanaged devices), MDM coverage gap (unenrolled IDP users with admins ranked first), declining admin MFA (admins still without MFA), service account growth (service accounts), SSO bypass growth (direct-auth apps ranked by user count), Entra legacy auth (users authenticating via legacy protocols), cloud admin legacy auth risk (exposed cloud admins), external user overrepresentation (external accounts), password spray (targeted accounts plus source IP), and category spend concentration (overlapping apps ranked by cost). Older non-drillable findings auto-resolve atomically via the Superseded tier of the auto-resolve loop on the next analysis run.

- **ITSM ticket linking and auto-close.** Remediation actions that create Jira, ServiceNow, Freshservice, or Zendesk tickets now return a clickable ticket URL in the action log. When the underlying finding is resolved, Thalian automatically closes the linked ticket.

- **Login event times in your local timezone.** Off-hours login findings now show the viewer's local timezone alongside the UTC stamp (e.g. "21:00 UTC (1:00 PM PDT)").

- **Dynamic identity-ceiling scoring.** Workspace risk score formula now scales with identity count rather than saturating at a fixed maximum. Scenario Builder deltas no longer show misleading "no improvement" results on workspaces with many findings.

- **Operational coverage.** Datadog added to the offboarding cascade so terminated identities flag for Datadog suspension alongside Okta, Entra ID, Google Workspace, and the other IDPs. The "AI agent count growing" rule title aligned to its landing-page name.

- **LiteLLM personal-email admin detection.** The `litellm_personal_email_admin` rule fires when a LiteLLM `proxy_admin` is registered on a personal email domain, closing the detection gap that previously covered only Anthropic and OpenAI. The sync handler now pulls the user roster from `/user/list` so each identity carries its role; the existing `/user/daily/activity` source doesn't expose role data. Older LiteLLM gateways (before v1.50) and master keys without admin scope still sync identities from activity records but skip the role enrichment without failing. Severity is high for `proxy_admin`, medium for other roles. Maps to SOC 2 CC6.1/CC6.2, ISO 27001 A.5.16/A.5.18, NIST CSF 2.0 PR.AA-01, and ISO 42001 A.6.2.2.

### Fixes

- **Actor badges distinguish AI agents from service accounts.** In the **Findings** page **By actor** view, each non-human identity's badge now reflects what the identity actually is, not the category of finding attached to it. Previously the view inferred "AI Agent" from the presence of an AI governance finding, so a human admin or a plain service account carrying such a finding was mislabeled **AI Agent**. The badge now reads the authoritative identity classification synced from your IdP, so true AI agents show the purple **AI Agent** badge while other non-human identities show an amber **Service account** badge, with a `· review` annotation when an account matches an AI framework naming pattern but hasn't been formally classified. Humans render as **User**. The summary band counts all non-human identities (AI agents and service accounts) with open findings.

- **Stuck OAuth findings now auto-resolve correctly.** Some findings on Zoom and Claude (and any other finding whose source data is the applications, entitlements, or audit-events table rather than a specific platform) were sitting open even when every connected integration was syncing cleanly. The auto-resolve gate didn't know how to map those rule-internal labels to a platform health check, so it bailed and the findings persisted. The gate now treats those labels as healthy whenever any connected integration is healthy. Affected findings clear automatically over the next two analysis cycles.

- **GitHub OAuth and personal access token connections work again.** GitHub's API silently returns 403 for requests without a User-Agent header, which broke OAuth signup (the org lookup failed and the callback came back saying "no organization found") and PAT validation (the verifier read the 403 as "token invalid"). All five GitHub API call sites now send the header. Fine-grained PATs scoped to specific organizations also pass through validation now.

- **OAuth-grant noise findings on Zoom, Claude, and similar platforms removed.** The "aged OAuth grant with no usage signal" rule was firing on platforms that don't expose per-grant last-used data through their APIs. With no real signal to anchor on, the finding was noise. The rule now only fires on data sources where last-used is observable. Existing noise findings auto-resolve.

- **"Users appearing in SaaS tools without IDP provisioning" finding no longer counts installed bots as ghost users.** Slack bots and apps (Claude, Sentry, Pipedream, your own custom bots) are non-human identities that legitimately have no IDP account, but the rule was counting them as missing humans. The rule now excludes `identity_type='service_account'` from both the ghost-creation count and the current-active-ghost count. The description also names the connected IDP (for example, "without a matching account in Google Workspace") instead of saying "any connected IDP," so the platform chips on the finding card match the prose. Auto-resolves for workspaces whose only previously-counted ghosts were bots.

- **License overrides no longer auto-classify apps as Approved.** Uploading a contract for an app (which records license cost, tier, and renewal metadata) was pinning that app into the Approved tab on the Applications page regardless of policy state, and the Revert button had no visible effect because it only clears the policy, not the license override. License data is contract and cost tracking, not a policy approval, so an app with a license override now falls through to Unsanctioned unless it is explicitly sanctioned, SSO-provisioned, or stamped sanctioned by sync data. Contract data is preserved and continues to drive the Source, Monthly Cost, Tier, and Renewal columns.

- **Compliance PDF export now includes all controls**. The PDF download on the Compliance page was capturing only the score summary (compliance percentage, passing count, failing count) and leaving the controls table blank. The export now produces a complete report including the full controls table regardless of any search or filter currently applied in the UI.

- **Impact Analysis Scenario Builder delta sync.** Scenario Builder cumulative delta now agrees with the Recommended Actions estimate. Two fallback paths in the score calculation were treating saturated scores as neutral instead of computing the true delta, producing misleading results on workspaces with many findings.

- **Multiple security and observability hardening.** Workspace isolation closed across all remediation paths. Slack approve/snooze flow closed four downstream bugs. Single-use guard added to AI-chat HMAC confirmation tokens. SSRF guard added to notification webhook URLs. Error message disclosure fixed across five endpoints. Approval TOCTOU race condition closed. PII-classified signup metadata moved from localStorage to sessionStorage. Five Sentry-flagged frontend bugs resolved. Framework score columns aligned to numeric type matching live DB. The "Terminated employee still active" finding mapped to SOC 2 CC6.7 and ISO 27001 A.6.5.

- **AI provider integrations validate admin keys at save time.** Anthropic, OpenAI, and LiteLLM connect attempts were accepting any non-empty key string and only surfacing the error on the first sync, typically as a 401 from the provider's organization usage endpoint. The connect modal now probes the same endpoint the sync handler uses and rejects the credential immediately with a specific error pointing you at the right type of key (Admin API Key from the provider's Console settings, not a regular API key) and where to create it. Hardening applied across every integration validator: probe timeout tightened from 30s to 10s so a slow upstream cannot consume the full request budget, and the shared SSRF blocklist expanded to cover Alibaba Cloud, Oracle Cloud, IPv6 link-local, and several AWS / GCP metadata aliases.

- **Per-app findings now surface on the affected identity's card.** OAuth and entitlement findings that attribute users in their payload (rather than via a direct identity FK) now correctly appear on the Identities page for the users they affect. Two rules also now populate the identity FK directly when exactly one user resolves, making single-user app findings attributable without changing the finding key or type. The Applications page per-app view now indexes grouped findings by app UUID so per-app finding lists are complete.

- **Disconnecting and removing an integration no longer leaves zombie findings.** Findings were being tagged with category aliases (`mdm`, `identity_provider`, `oauth`, ...) instead of the actual platform ID, so the integration-removal cleanup query never matched them when the last platform in a category was removed (for example, disconnecting and removing Fleet in a Fleet-only MDM environment left zombie findings with `data_source: "mdm"` that nothing could clean up). All findings now pass through a single normalization chokepoint at persist time that expands category aliases to real connected platform IDs — entity-first when available, category-wide otherwise. Unresolvable aliases are dropped. The integration-removal flow now also sweeps legacy alias-encoded rows, gated to only fire when removing the platform leaves its category with zero connected platforms. Sweep activity is recorded in the audit log under `orphaned_aliases_swept`.

- **Notification deep-links repaired.** Outbound Slack, Microsoft Teams, email, and webhook alerts built deep-links to a `/risks` route that no longer exists (it was renamed to `/findings`), so clicking through dropped you on the dashboard catch-all instead of the specific finding. URLs now build through a centralized helper driven by `SITE_URL`, and per-finding deep-links carry the `?finding={uuid}` query param so the detail panel opens directly to the finding being notified.

---

## April 2026

### New Features

- **Attack Surface Map**. New interactive SVG graph in Causality Insights connects identity entry points, attack vectors, and at-risk platforms in a single view. Root cause and systemic pattern cards pre-fill the AI assistant on click.

- **Attack chain redesign**. Attack chain card rebuilt as a structured diagram: entry point → animated attack vector node → platform fan with intensity-colored ticks proportional to entitlement exposure.

- **Login geolocation**. Finding detail panels now show city, region, country, and ISP for login context. Processed in-house via MaxMind GeoLite2 on Cloudflare R2, no customer IP sent to third parties.

- **Grouped findings**. 8 high-volume rules now emit one grouped finding instead of one per identity. Severity scales with scope (e.g., 50%+ MFA gap escalates to critical). Affects: active user with no device, admin without MFA, stale admin, MFA coverage gap, password-only auth, cross-platform privilege drift, cross-platform offboarding gap, cross-platform MFA gap.

- **Finding consolidation**. Shadow IT sensitive-scope and broad OAuth write-access findings consolidated into one finding per workspace (5+ apps = critical). GitHub org owner + GCP owner/member not-in-IDP findings similarly grouped.

- **Per-admin OAuth revoke**. Admin excessive OAuth findings are now one per admin with per-app inline revoke. No stored OAuth client ID required.

- **Custom entity names in finding titles**. 11 per-entity rules now include the specific person's name or email in the finding title for faster triage.

- **Slack App Directory**. Thalian is now listed in the Slack App Directory. Install directly from Slack via `app.thalian.ai/api/slack-install`.

### Security

- **HMAC key isolation**. Webhook and AI chat action HMAC keys domain-separated via HKDF.
- **Single-use action tokens**. HMAC confirmation tokens for AI-initiated remediation are consumed on first use.
- **AI chat tool gating**. `trigger_sync` requires `manage_integrations` role; `run_analysis` requires `analyze` role.

### Fixes

- **Automation policy matching**. Automation was silently firing on wrong findings when policies had an empty rule ID list. Fixed with an explicit `match_mode` column. Check the Policies page, violation counts may change.
- **Fleet encryption and compliance**. Encryption and compliance were showing "Unknown" for Fleet devices. Fixed by fetching per-host detail endpoints.
- **Device OS column**. Now shows OS version string, not raw platform identifier.
- **AI chat truncation**. Max tokens raised to 4096 with pagination for long responses.
- **OAuth finding "Authorized by"**. Now correctly aggregates users across all apps in a consolidated finding.

### Improvements

- **Bulk app policy actions**. Select multiple apps on the Applications page and approve, flag, or block them in one action. Floating action bar with Select all shortcut. Available to admins and security roles.

### Integrations

- **Datadog**. Connect Datadog with an API Key + Application Key. Thalian syncs users and role assignments to detect Datadog admins with no corporate identity (critical), admin accounts without MFA (when no SSO is in use), standard users outside IDP lifecycle controls, and offboarded employees who retain full infrastructure visibility. 4 detection rules.

- **Zoom**. Connect your Zoom organization to detect users and admins not in your corporate IDP, SSO enforcement gaps, offboarded employees with active Zoom accounts, and stale unused seats. 5 detection rules.

- **Box**. Connect Box to detect IDP gaps, offboarded employees retaining file access, and external sharing activity. Cross-references with IDP data to surface departed employees who still have access to corporate files. 4 detection rules.

- **GitLab**. Connect a GitLab group via Group Access Token for developer access intelligence. Syncs members, projects, deploy keys, and group tokens. Works with GitLab.com and self-hosted. 8 detection rules including Maintainer/Owner not in IDP (critical), MFA gaps, external member access, write deploy keys, non-expiring group tokens, offboarding gaps, and stale members.

- **GitHub secret scanning**. 2 new rules using GitHub Advanced Security data: unresolved secret scanning alerts (critical) and repeated push protection bypasses (high).

- **CrowdStrike Spotlight**. 2 new rules: unpatched critical/high CVEs on managed devices, and high-severity vulnerabilities on admin-access devices.

- **Entra PIM activation monitoring**. 2 new rules: PIM role activated without justification, and PIM activation outside business hours.

- **Okta high-risk signin**. 1 new rule fires on completed sign-ins flagged as high risk by Okta's risk engine.

- **Box Shield + departing employee downloads**. 2 new rules: unresolved Box Shield threat alerts, and mass file downloads by offboarded employees.

- **Salesforce permission set escalation**. 2 new rules: admin-equivalent permission set assignment for non-admin users, and active session-based permission escalation.

- **SentinelOne Ranger**. 1 new rule: unmanaged network devices discovered by Ranger that lack a SentinelOne agent.

- **Confluence + Jira audit rules**. 2 new rules: space permission changes in Confluence and permission scheme changes in Jira.

### New Features

- **Cross-platform brute-force detection**. Detects credential stuffing attacks by correlating failed login events across identity providers and SaaS apps. Fires when multiple IPs attempt repeated failed logins against the same account. Escalates when the same email shows failures on both the IDP and downstream SaaS platforms, a coordinated attack no single tool can see.

- **341 detection rules**. The analysis engine now runs 341 rules (up from 173 in mid-March), covering identity security, access hygiene, device posture, behavioral anomalies, shadow IT, license waste, compound cross-platform risks, and drift signals.

- **Cross-platform compound rules**. 14 new rules that require data from 3+ connected platforms to fire, findings that no single tool can surface.

- **AWS IAM deep analysis**. Credential Report, root MFA status, CloudTrail root activity, IAM role trust policy analysis. 11 AWS rules total.

- **GCP service account key monitoring**. Detects unrotated user-managed keys and Workload Identity adoption gaps.

- **Salesforce session and export detection**. Profile permission analysis, session IP restrictions, and bulk data export event detection. 9 Salesforce rules total.

- **Entra ID Identity Protection and PIM**. Risky users, PIM permanent role assignments, admin MFA method analysis, guest invitation policies. 6 new rules.

- **Okta security configuration analysis**. ThreatInsight, MFA enrollment policies, password policies, API token hygiene, session settings. 14 Okta rules.

- **AI context for all platform metadata**. The AI assistant now surfaces detailed security configuration data from all connected platforms.

- **Access review bulk decisions + overdue reminders**. Bulk approve/revoke in access review campaigns. Overdue reminder emails sent automatically to reviewers.

- **Trial extension + compliance preview**. Free-tier users can self-serve a trial extension. Compliance page visible in preview mode for free users.

- **Security Posture Timeline**. New History page (**Reports → Timeline** or the dashboard "Monitoring since" badge) shows posture score over time, MFA coverage trend, compliance rate, and a narrative event log of grade shifts, MFA drops, new integrations, and remediation milestones.

- **Integration Coverage Widget**. Dashboard now shows a 6-category coverage bar (Identity, Endpoint, HR, Security, Cloud, Comms) with per-category status dots and a CTA for the highest-priority gap.

- **MCP server + API Keys**. Query your Thalian workspace from Claude Code using the Model Context Protocol. Generate an API key in **Settings → API Keys** and use six available tools: `get_risk_score`, `list_findings`, `lookup_identity`, `get_integrations`, `get_posture_summary`, and `trigger_sync`. API keys are workspace-scoped and read-only.

- **Remediation playbooks**. Multi-step automated response sequences on the Policies page. Build ordered playbooks (e.g., "Offboard terminated employee") that run across platforms with per-step auto-execute or approval controls. Available on Pro and Enterprise.

- **PDF evidence export for access reviews**. Access review campaigns now include a PDF export of reviewer decisions, timestamps, and entity details for audit documentation.

- **Compliance Trend tab**. The trend chart now tracks SOC 2 and ISO 27001 compliance scores over time. Scores are computed each analysis run from live open findings mapped to each framework's controls, then stored in posture history so the chart shows real compliance trajectory. Historical data backfilled from existing finding timestamps.

- **In-app service status banner**. Dismissible banner appears during active incidents or service degradations.

- **Free plan identity usage bar**. Free plan workspaces now see a live usage bar showing monitored identities vs. the plan limit, with a clear upgrade path.

- **390 detection rules**. +40 new platform-depth rules for Intune, Jamf, Fleet, Workspace ONE, Iru, Workday, Microsoft 365 (Teams/SharePoint/Outlook), JumpCloud, and OneLogin. Highlights: non-compliant Intune admin with SaaS access, Fleet CVE + sensitive-app owner, Workday contingent worker with permanent-employee access, Teams offboarded user still a guest, SharePoint anonymous link policy open, Outlook external mailbox delegation, MDM × IDP compound rules (unmanaged device with IDP SSO access, terminated device still enrolled, BYOD owner with admin entitlements), JumpCloud/OneLogin MFA and policy coverage gaps. No new integrations required, all rules fire on existing synced data.

### Improvements

- **Workspace risk score rebuilt**. Linear, CVSS-aligned formula replaces sigmoid curve that saturated at high risk levels and caused all Recommended Actions point deltas to show ±0. Each finding now produces a proportional, non-zero score movement. Cost-only findings (license waste) and metadata-noise rules excluded from the workspace score. Six rules reclassified from low to medium: Okta factor enrollment optional, Okta network zone bypass, Okta ThreatInsight disabled, Entra Security Defaults disabled, GitHub default branch protection missing, SharePoint external sharing activity.

- **Webhook destination picker**. Two-section picker (Workflow Automation: Workato, Zapier, n8n, Gumloop, Make; SIEM & Observability: Datadog, Splunk, Elastic, Panther, Sumo Logic) with per-destination setup hints
- **Webhook event improvements**. `finding_detected` now fires only for new findings (not all open findings every run); new `finding_resolved` event when a condition clears; `analysis_completed` gains `new_findings_count`; `finding_detected` payload enriched with `finding_id`, `action_type`, `source_integrations`
- **Remediation action buttons** across all finding types
- **Application sanctions** directly from the Applications page
- **Finding deduplication**. actioned findings no longer re-created on next analysis
- **GCP IAM role names in findings**. findings now display specific role names (Owner, Editor, Viewer)
- **Analysis cooldown reduced** from 5 minutes to 1 minute
- **Sidebar findings count** updates immediately after analysis
- **Analysis error reporting**. insert errors now reported to Sentry and audit log
- **Landing page overhaul**. OG image for social sharing, "See Live Demo" CTA, rendered FAQ section, mobile nav fix, Docs link in top nav
- **Demo experience**. Guided 5-step walkthrough, demo banner with conversion CTA, streamlined login with request access form
- **Signup hardening**. Company name required, personal email domains blocked
- **SSO error messaging**. Admin self-service guidance when no SSO configured
- **Iru naming**. Kandji references updated to "Iru (formerly Kandji)"
- **FAIR-aligned entity risk scoring**. Entity risk scores now use a FAIR-aligned model for more meaningful, comparable scores across identity types
- **Integration error classification**. Errors classified by type (auth expired, config invalid, rate limited). Sidebar badge and app-wide banner for critical errors
- **Blast radius orbit visualization**. Interactive orbit diagram replaces flat list on entity detail blast radius view
- **Behavioral baseline accuracy**. Directory login events excluded from baselines when a dedicated IDP is connected
- **Finding category consolidation**. "Configuration" category folded into "Access Risk" and "Identity Security"
- **Free plan identity usage bar**. Live usage bar showing monitored identities vs. plan limit with upgrade path
- **Pro data retention**. Extended from 90 days to 1 year for all workspace data and audit logs

### Fixes

- **SSO finding accuracy for Google Workspace-only environments**. SSO findings now correctly surface ungoverned OAuth grants (not "SSO bypass") when Google Workspace is the only IDP. Titles, descriptions, and remediation guidance updated.
- **SSO finding accuracy, Google-only ratio and payload corrections**. Follow-up: `sso::high_direct_auth_ratio` now requires a majority threshold before firing; entity payloads for Google-only paths corrected to report `oauth_count` instead of `direct_count: 0`.
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
- Fixed billable identity count inflated by SaaS-only accounts, now IDP/directory users only
- Fixed MTTR calculations including auto-resolved findings
- Fixed device page managed/unmanaged tab split, now a single unified view
- Fixed behavioral baseline suppression scope applying too broadly
- Downgraded `suspicious_programmatic_login` from high to medium severity
- Fixed Google OAuth WebViews warning
- Fixed billing flow, plan gate incorrectly blocking some Pro actions
- Fixed approval request emails double-sending

### Security

- **npm supply chain hardening**. In response to the March 30 Axios npm supply chain attack (CVE pending, attributed to North Korean threat actor UNC1069), we audited all dependencies and confirmed Thalian is not affected, axios is not in our dependency tree. We've additionally hardened our build pipeline: npm audit now blocks deployments on high-severity findings, postinstall scripts from transitive dependencies are disabled by default, all dependency versions are pinned exactly, and lockfile integrity validation has been added to CI.

- **AI chat prompt injection hardening**. Topic-scoping guardrails added to the AI assistant to prevent prompt injection and constrain responses to IT security topics.

- **RBAC audit**. Closed role gating gaps across integration management, workspace settings, billing actions, and agentic remediation approvals. No data was exposed.

- **Workspace ONE vendor reference**. Updated references from "VMware Workspace ONE" to "Omnissa Workspace ONE" following the acquisition and rebrand.

---

## March 31, 2026

### New Features

- **Entra ID: Conditional Access policy detection**. Thalian now fetches and analyzes your Entra ID Conditional Access policies automatically after each sync (requires re-authorizing the Microsoft connection to grant `Policy.Read.All`). Three new detection rules fire when CA policies are available: MFA policy in report-only mode (logs violations but never blocks), disabled MFA policy (potential regression if previously enforced), and admin accounts explicitly excluded from all MFA-requiring CA policies. The AI assistant also gains a Conditional Access context block and can answer questions about which policies are enforced vs report-only, whether MFA is actually blocking sign-ins, and which admins aren't covered. Existing Entra connections without the new scope continue working, CA rules stay silent until re-auth.

- **Okta System Log correlation**. Three new Okta-specific detection rules now use System Log data to surface credential and authentication risks that event-by-event inspection misses: failed MFA spike (5+ failed MFA challenges per user in the sync window, potential credential stuffing), MFA factor disabled (user or admin disabled an MFA factor, elevated severity for admin accounts), and user-reported compromise (user clicked "This wasn't me" in Okta, highest-confidence indicator of active account takeover). Okta System Log has been synced since launch; these rules make that data actionable without any new connection steps.

### Improvements

- **GCP IAM privilege analysis**. GCP IAM now detects 4 new privilege and configuration risks beyond IDP gap detection: owner role sprawl per project, service accounts with admin-level roles, users with admin access across 3+ projects, and systemic over-provisioning (>50% of users at Editor or higher). These rules fire even when Google Workspace is the IDP, previously, GCP findings only appeared when users existed outside the corporate identity provider.

---

## March 30, 2026

### Integrations

- **Workday HR**. Connect Workday to cross-reference employee lifecycle data against your identity providers and SaaS access. Thalian syncs active and terminated workers from Workday and detects terminated employees who still have active IDP accounts, SaaS entitlements, or managed devices. Joins with Okta, Entra ID, Google Workspace, JumpCloud, OneLogin, Intune, Jamf, and all connected SaaS platforms. Read-only, uses Workday's REST API with basic auth credentials. Adds to the existing HR intelligence layer alongside Rippling and BambooHR.

### New Features

- **Compliance: evidence export (Enterprise)**. The Compliance page now includes PDF and Excel evidence pack export for Enterprise workspaces. Pro users see a locked "Export evidence" button with an upgrade prompt. The export includes control status, mapped rules, open findings, and a timestamp, formatted for handing directly to an auditor.

- **Compliance: audit log tab**. A dedicated Audit Log tab is now available on the Compliance page, showing a filterable, searchable feed of all user and system actions. Pro workspaces see 30-day history with CSV export; Enterprise sees 1-year retention. Free users see the plan gate.

- **Integration library redesign**. The integration browser has a new card layout and filter bar. Cards now show category, connection status, and sync stats. Filter by category (Identity, Device, HR, Cloud, etc.) to find what you need faster.

- **Clickable stat pills on integrations**. Stat pills on connected integration cards (e.g. "42 identities", "7 findings") now navigate directly to the relevant filtered view, Identities, Applications, Devices, or Findings, scoped to that integration.

### Improvements

- **Plan tier copy**. The billing and upgrade pages now accurately reflect what each plan includes.

### Fixes

- **Display labels throughout**. Raw internal identifiers (e.g. `notify_user`, `google_workspace`, `non_compliant`, `in_progress`) no longer appear in the UI. Action types, remediation statuses, compliance statuses, and audit event types are now shown as readable labels everywhere.
- **Audit log retention**. The audit log now correctly shows 90-day history for Pro workspaces (previously displayed "30-day history" due to a hardcoded mismatch).
- **Compliance deep links**. "View findings →" links inside expanded compliance controls now navigate correctly to the Findings page filtered to that rule.
- **AI chat MFA/login accuracy**. The AI assistant no longer reports MFA or login status for platforms that don't expose that data (e.g. GitHub, Slack), preventing misleading "no MFA" statements for accounts where MFA is managed by an IDP.

---

## March 29, 2026

### Integrations

- **Salesforce**. Connect Salesforce to detect CRM access gaps between your Salesforce org and your corporate identity provider. Thalian syncs all active and inactive Salesforce users and cross-references against Okta, Entra ID, Google Workspace, JumpCloud, and OneLogin. Fires four new findings: Salesforce admin not in IDP (critical), Salesforce user not in IDP (high), stale Salesforce user whose IDP account is suspended or deprovisioned but CRM access remains active (high), and connected app authorized by an unknown user outside the IDP (medium). Read-only, no write permissions requested.

### Improvements

- **Slack alerts: Dismiss and Snooze from Slack**. Security alerts sent to Slack now include Dismiss and Snooze 7d buttons directly on every alert card. Both actions update the original Slack message in place with a confirmation line. All actions are signature-verified and written to the immutable audit log.

- **Okta: upgraded to OAuth 2.0 client credentials**. Okta sync now authenticates using OAuth client credentials instead of a static SSWS API token. More secure, token rotation is handled automatically.

---

## March 28, 2026

### Integrations

- **AWS IAM**. Connect AWS Identity and Access Management to detect IAM users that exist outside your corporate IDP lifecycle controls. Detects admin-level accounts with no matching IDP identity, IAM users without MFA enrolled, and stale IAM users whose IDP account has been suspended or deprovisioned.

- **GCP IAM**. Connect Google Cloud Platform to detect IAM access gaps between your GCP projects and your corporate identity provider. Fires four findings: GCP project owner not in IDP (critical), GCP member not in IDP (high), public IAM binding via `allUsers` or `allAuthenticatedUsers` (critical), and stale IAM binding for a suspended or deprovisioned user (high).

### New Features

- **Access review campaigns**. Run structured user access certification campaigns directly in Thalian. Scope by department or application, work through entitlements, approving, revoking, or granting time-limited exceptions. Revoke decisions automatically open an ITSM ticket. Completed campaigns export to CSV as audit evidence for SOC 2 (CC6.3), ISO 27001, and HIPAA reviews.

- **Claude-driven agentic remediation planner**. After every sync, Claude Sonnet reviews all new findings and decides which ones need action. Queued actions now include a "Claude's reasoning" block explaining the recommendation and why the sequencing is correct.

---

## March 26, 2026

### New Features

- **"Since your last session" AI brief**. The dashboard AI brief now opens with what changed since you last logged in, personalized context on every login.
- **Cross-platform perspective view on findings**. Expanding a cross-platform finding shows a side-by-side breakdown of what each connected platform sees vs. what Thalian sees by joining them.
- **Live cost counter on integration discovery**. Connecting a new integration that reveals license waste animates the cost counting up as findings are scored.
- **Drift velocity projection**. Posture sparklines now show a dashed forward projection via linear regression, with projected breach dates for declining metrics.
- **AI chat contextual actions**. When the AI mentions a high-severity finding, it surfaces the available remediation action: "You can suspend her in Okta directly from here if needed."
- **Behavioral anomaly detection**. Rules detect unusual login patterns, off-hours spikes, and sudden app access changes vs. per-user baselines.
- **7 new cross-platform compound rules**. Findings requiring 3+ connected data sources: terminated employee with dual exfiltration paths, admin on compromised device with active EDR threat, coordinated multi-platform admin actions within 30 minutes, and more.
- **Shadow admin detection**. Identifies users who are standard users in the IDP but hold admin roles in 3+ SaaS apps, the privilege gap no single tool can see.
- **Benchmark SaaS pricing**. License waste findings estimate cost impact using per-user pricing for 40+ SaaS apps, without requiring contract uploads.

### Improvements

- **Hourly auto-sync**. Connected integrations now sync every hour (previously every 6 hours).
- **Findings page streamlined**. Value badges consolidated, sort controls merged, layout tightened.

---

## March 25, 2026

### New Features

- **SSO coverage per identity**. The Identities page now shows how many of each user's apps are SSO-managed vs. direct-auth, with 7 new detection rules for SSO gaps (admin with direct-auth apps, executive bypassing SSO, offboarded user with unreachable direct-auth apps, and more).
- **3 new drift signal rules**. SSO coverage declining, termination-to-access-removal lag growing, and ghost identity growth, all requiring 3+ data sources to fire.
- **Automatic remediation after every sync**. Safe actions execute immediately; risky actions queue for admin approval and trigger an email notification.
- **AI Risk Summary on identity detail**. Opening an identity with findings shows a Claude-generated narrative covering risk score, MFA, app access breadth, device compliance, and blast radius.

---

## March 23, 2026

### Improvements

- **In-app support form**. "Contact support" now opens a proper support form with ticket confirmation email, instead of a chat widget.

---

## March 20, 2026

### New Features

- **SAML 2.0 SSO (Enterprise)**. Configure SAML 2.0 single sign-on from Settings → Security → SSO/SAML. Supports SP-initiated and IdP-initiated login. Works with Okta, Azure AD, and any SAML-compatible IdP. SSO users are auto-provisioned on first sign-in.
- **Security Posture score history and sparkline**. The Security Posture stat now shows a live sparkline and delta vs. the previous analysis run.

### Improvements

- **AI chat**. Full visibility into remediation history (last 30 days), richer entity data (named users, app categories, OS versions), what-if simulation tool, and stale access analysis.
- **Security Posture score**. Unified 0–100 score with sigmoid normalization and letter grade (A–F), replacing the raw risk score. Dashboard and AI assistant now always agree.

---

## March 19, 2026

### New Features

- **AI-reasoned remediation**. Ask Claude to analyze all open risks for an entity and propose a sequenced action plan with reasoning.
- **Public status page**. Real-time platform health at [status.thalian.ai](https://status.thalian.ai) with incident history and email subscription.
- **Layer 3 behavioral baselines**. Per-entity anomaly detection across logins, apps, locations, and failed auth.

### Improvements

- **Performance**. Initial app bundle reduced by 69%; database queries parallelized.
- **Auto-sync reliability**. Integrations now sync in parallel.

### Security

- Auth guards and workspace scoping added to 7 previously unguarded API endpoints.

---

## March 2026

### New Features

- **Impact Analysis page**. Model remediation scenarios before executing them with the scenario builder.
- **KPI Dashboard and Goals Tracker**. Set measurable security goals with target values, deadlines, and AI-recommended actions across 14 metrics.
- **Policy auto-generation**. Auto-generated security policy drafts based on connected integrations and active findings.
- **Causality Insights**. Cross-platform finding correlation that surfaces connections between related findings.
- **Agentic remediation**. Automated remediation with three tiers for Pro and Enterprise workspaces.

### Integrations

- Added **Cisco Meraki**, **Confluence**, **SharePoint**, **Freshservice**, **Zendesk**
- 24 platforms now supported across 7 categories

---

## February 2026

### New Features

- **AI Brief**. AI-generated natural language summary of workspace security posture.
- **Remediation approval workflow**. Agent-initiated actions on high/critical findings require Security Analyst approval.
- **Sync events log**. View all data changes detected during integration syncs.

### Integrations

- Added **SentinelOne**, **Hexnode**, **Jira Service Management**

### Improvements

- **MFA enforcement**. Workspace admins can now require TOTP-based MFA for all members.
- **MTTR tracking**. Mean Time to Remediate metrics by severity, with trend charts.

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
