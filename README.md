<div align="center">
  <img src="./logo.svg" alt="Thalian" width="280" />
  <br /><br />
  <strong>AI-native IT intelligence and orchestration platform</strong>
  <br />
  Cross-platform identity risk, shadow IT detection, and automated remediation for IT and security teams.
  <br /><br />
  <a href="https://app.thalian.ai/signup"><strong>Get started →</strong></a>
  &nbsp;&nbsp;·&nbsp;&nbsp;
  <a href="https://docs.thalian.ai">Docs</a>
  &nbsp;&nbsp;·&nbsp;&nbsp;
  <a href="https://status.thalian.ai">Status</a>
  &nbsp;&nbsp;·&nbsp;&nbsp;
  <a href="https://github.com/thalian-ai/thalian/releases">Changelog</a>
</div>

---

## What is Thalian?

Thalian connects your identity providers, SaaS applications, device managers, HR systems, and cloud infrastructure — then joins them to surface security risks that are invisible in any single tool.

- **Cross-platform identity risk** — Find the admin who has MFA in Okta but direct-auth access to 6 SaaS apps. Find the offboarded employee who still has an active GitHub seat, Salesforce login, and a managed device.
- **Shadow IT and OAuth exposure** — Detect unsanctioned AI tools, OAuth apps with write access to email and calendar, and apps that bypass SSO entirely.
- **Device posture correlation** — Cross-reference device compliance and EDR health against the identities that own them. Surface the admin on a compromised endpoint.
- **AI-reasoned remediation** — Claude analyzes findings in context, proposes sequenced action plans, and executes safe actions automatically while queuing risky ones for approval.
- **Access review campaigns** — Run structured user access certifications scoped by department or application, with automatic ITSM ticket creation on revoke decisions and CSV export for audit evidence.

---

## Supported integrations

### Identity Providers
| Platform | Sync | Rules | Remediation |
|----------|------|-------|-------------|
| Okta | ✅ | ✅ 14 Okta-specific rules: MFA spike, factor disabled, account compromise, API token security, config audit, password/session policy | ✅ Suspend, revoke OAuth token, block app, remove admin role, revoke license, remove from group, rotate credentials |
| Microsoft Entra ID | ✅ | ✅ 10 Entra-specific rules: Conditional Access policy gaps, app registration secrets, legacy auth, B2B guest staleness, security defaults | ✅ Suspend, revoke OAuth token, block app, remove admin role, revoke license, remove from group, rotate credentials |
| Google Workspace | ✅ | ✅ | ✅ Suspend, force password change, revoke OAuth token, revoke sessions, block app, remove admin role, revoke license, remove from group, rotate credentials |
| JumpCloud | ✅ | ✅ | ✅ Suspend, remove admin role, remove from group |
| OneLogin | ✅ | ✅ | ✅ Suspend, force password change, revoke sessions, force MFA enroll, remove admin role |

### Device Management
| Platform | Sync | Rules | Remediation |
|----------|------|-------|-------------|
| Microsoft Intune | ✅ | ✅ | ✅ Enroll device |
| Jamf Pro | ✅ | ✅ | ✅ Enroll device |
| Kandji | ✅ | ✅ | ✅ Enroll device |
| Hexnode | ✅ | ✅ | ✅ Device actions |

### Endpoint Security
| Platform | Sync | Rules | Remediation |
|----------|------|-------|-------------|
| CrowdStrike Falcon | ✅ | ✅ Degraded sensor, contained host | ✅ Contain host, initiate scan |
| SentinelOne | ✅ | ✅ Active threat, offline sensor | ✅ Agent actions |

### HR & People
| Platform | Sync | Rules |
|----------|------|-------|
| Rippling | ✅ | ✅ 13 lifecycle rules: terminated access, offboarding delay, ghost employee, department drift, manager mismatch, compound cross-platform |
| BambooHR | ✅ | ✅ 13 lifecycle rules (same as Rippling) |
| Workday | ✅ | ✅ Terminated access |

### Cloud Infrastructure
| Platform | Sync | Rules |
|----------|------|-------|
| AWS IAM | ✅ | ✅ 11 rules: admin/user not in IDP, no MFA, stale users, access key rotation, root account security, unused roles, cross-account trust |
| GCP IAM | ✅ | ✅ 12 rules: owner/user not in IDP, public bindings, owner sprawl, SA key rotation, cross-project admin, org-level bindings, custom roles |
| Azure IAM | ✅ | ✅ 4 rules: owner/user not in IDP, stale role assignments, service principal with owner role |

### Communication
| Platform | Sync | Rules | Remediation |
|----------|------|-------|-------------|
| Slack | ✅ | ✅ Offboarded users, guests | Notify only |
| Slack Enterprise Grid | ✅ | ✅ Offboarded users, guests | ✅ Deactivate via Admin API |
| Microsoft Teams | ✅ | ✅ Offboarded user activity | Notify only |
| Microsoft Outlook | ✅ | ✅ Mailbox forwarding rules | — |

### Collaboration
| Platform | Sync | Rules | Remediation |
|----------|------|-------|-------------|
| SharePoint | ✅ | ✅ External sharing | — |
| Confluence | ✅ | ✅ Suspended user access | — |

### Developer Tools
| Platform | Sync | Rules | Remediation |
|----------|------|-------|-------------|
| GitHub | ✅ | ✅ Outside collaborators, org owners | ✅ Revoke access, remove org member |

### CRM
| Platform | Sync | Rules | Remediation |
|----------|------|-------|-------------|
| Salesforce | ✅ | ✅ 9 rules: admin/user not in IDP, stale access, connected apps, API-only users, session security, data export, profile permissions | — |

### ITSM (ticket creation)
Jira · ServiceNow · Freshservice · Zendesk

### Network (inventory)
Cisco Meraki · Auvik

---

## Key capabilities

**290+ analysis rules** across 10 categories — identity security, access hygiene, shadow IT, device posture, license waste, behavioral anomaly, drift signals, compound risk, access risk, and configuration.

**AI assistant** — Ask anything about your environment. "Which admins don't have MFA?" "Show me everyone with access to Salesforce who isn't in Okta." "What changed since yesterday?" Powered by Claude.

**Behavioral baselines** — Per-user anomaly detection that flags deviations from established patterns: login frequency, off-hours access, failed auth spikes, and sudden OAuth grant surges.

**Compound findings** — Rules that require 3+ data sources to fire, including terminated employees with dual exfiltration paths, admins on compromised devices, and coordinated multi-platform privilege changes.

**Automated remediation** — Three tiers: auto-execute (safe actions like create ticket, notify user), auto-queue (risky actions like suspend user require approval), never auto (retire device, remote lock). Approval workflows via Slack, Teams, or the web UI.

**Compliance mapping** — SOC 2, ISO 27001, and HIPAA control coverage mapped to findings. Evidence export (PDF + Excel) for auditors. Access review campaigns with CSV export.

---

## Getting started

1. [Sign up](https://app.thalian.ai/signup) — free plan, no credit card required
2. Connect your first integration (Okta, Google Workspace, or Entra ID recommended)
3. Thalian runs its first analysis automatically — findings appear within 2 minutes
4. Connect a second integration to unlock cross-platform findings

[Full setup guide →](https://docs.thalian.ai/getting-started)

---

## Plans

| | Free | Pro | Enterprise |
|--|------|-----|------------|
| Identities | 25 | 500 | Unlimited |
| Integrations | 3 | Unlimited | Unlimited |
| AI queries/day | 25 | 100 | Unlimited |
| Auto-remediation | — | ✅ | ✅ |
| Compliance mapping | — | ✅ | ✅ |
| Access reviews | — | ✅ | ✅ |
| Data retention | 7 days | 90 days | Unlimited |
| SSO / SAML | — | — | ✅ |
| IP allowlisting | — | — | ✅ |
| Audit log (1 year) | — | — | ✅ |

[View pricing →](https://thalian.ai/#pricing)

---

## Security

- All integration credentials encrypted at rest with AES-256-GCM
- Immutable audit log with SHA-256 integrity hashing
- Row-level security enforced on all database tables
- All workspace data is strictly isolated — no cross-tenant access is possible
- SOC 2 and ISO 27001 controls mapped and tracked in-product

To report a security vulnerability, see [SECURITY.md](./SECURITY.md).

---

## Support & feedback

- **Documentation:** [docs.thalian.ai](https://docs.thalian.ai)
- **Status:** [status.thalian.ai](https://status.thalian.ai)
- **Bugs & feature requests:** [Open an issue](https://github.com/thalian-ai/thalian/issues/new/choose)
- **Support:** Use the support form inside the app (user menu → Contact support)
- **Security:** security@thalian.ai

---

<div align="center">
  <sub>© 2026 Thalian. All rights reserved. Proprietary software — source not available.</sub>
</div>
