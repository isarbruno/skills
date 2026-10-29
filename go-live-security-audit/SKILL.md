---
name: go-live-security-audit
description: "Use when someone wants to know whether a web app, API, webhook flow or internal tool that is or will be reachable from the internet is safe, before or right after go-live. Phrasings: \"security audit\", \"security check\", \"is this safe to go live\", \"before go-live\", \"pentest our app\", \"check for data leaks\", \"harden this app\", \"Sicherheitscheck\", \"Security-Audit\", \"Sicherheitsaudit\", \"ist das sicher\", \"ist das sicher online zu stellen\", \"bevor wir live gehen\", \"vor dem Go-live prüfen\", \"Datenleck prüfen\". Covers code, config, dependencies, secrets, deployment, host, live URL and integrations, and verifies every finding. Only for systems you own or operate. Not for ISO 27001 or customer audit preparation, security questionnaires or reviewing a single code diff."
user-invocable: true
---

# Go-Live Security Audit

Find what an attacker on the internet could do to a system we built, before someone does. One run covers the code, the configuration, the dependencies, the deployment, the host, the live URL and the integrations. Every finding is verified before it is reported.

Condensed from Trail of Bits skills (see `NOTICE.md`). Their core rule holds here too: pattern recognition is not analysis. A finding without a traced path from an attacker to an impact is an open question, not a finding.

## Hard rules

1. **Only our own systems.** Audit only what the user owns or operates. Confirm the target list (repo paths, domains, hosts) in phase 0. Never probe third-party services.
2. **Live probes stay harmless.** Read-only requests, at most one per second, no brute force, no fuzzing, no load tests, no form submissions that send mail or write data. On a shared host, probe only the target's domain. Anything beyond this needs the user's OK first.
3. **Servers are read-only.** Read configs, list ports and processes. Never change, restart or install anything on a server during the audit. Fixes come after the report and need the user's OK.
4. **Never print a secret.** Report a found secret by file, line, type and at most its first four characters. Never put a secret into the report, a subagent prompt or a tool that leaves the machine.
5. **No finding without the gate.** Every candidate goes through `references/verification-gate.md`. A candidate that fails the gate is dropped or moves to open questions.
6. **Say what did not run.** A skipped phase or a failed tool goes into the coverage table. Partial coverage presented as a clean result is worse than no audit.

## Output

- `<repo>/security-audit/<YYYY-MM-DD>/CONTEXT.md`: inventory and entry-point map (phases 0 and 1).
- `<repo>/security-audit/<YYYY-MM-DD>/REPORT.md`: the report (phase 9).
- Raw tool output goes to the scratchpad, never into the repo. It can hold matched secrets.

Without a repo, write both files to the scratchpad and say so.

## Phases

### 0. Scope and inventory

Write down, from the code, the project docs (CLAUDE.md, README, handoff notes) and the user:

- **Targets:** repo paths, public domains, hosts, other exposed endpoints (webhooks, automation workflows, cron jobs).
- **Stack and deployment:** language, framework and version, database, containers, reverse proxy, what else runs on the same host.
- **Data:** which personal or customer data the system stores or moves, and where it goes. This sets the impact of every finding (GDPR Art. 32).
- **Roles and trust boundaries:** anonymous, each user role, admins, services. How each one authenticates.
- **Secrets:** every secret the system uses, where it lives (env file, CI, workflow credential), who can read it.

**No-code / managed-backend apps** (Lovable, Bolt, v0, Replit on Supabase or Firebase): you usually have no source repo, and the frontend talks straight to the backend with a public client key that ships in the bundle (not a leak). The backend's row-level rules are the whole security model, not server code, and signup is often open to the world so the decisive question is what a logged-in outsider can reach, not what an anonymous one can. Inventory the backend, tables, RPCs, storage buckets and edge functions from the client JS bundle, then run `references/no-code-supabase.md` for phases 2, 6 and 7.

If the target list is unclear, confirm it with the user in one message. Then continue without further questions.

### 1. Context and entry points

From Trail of Bits audit-context-building: understand before hunting. List every entry point: page routes, API routes, server actions, webhooks, scheduled jobs, scripts on the server. For each one record who can reach it, which check guards it (`file:line`), what it reads and writes, and what it trusts. Mark every assumption that nothing enforces as `nothing found`. Those are the best leads for phase 2.

Follow the calls. A route looks guarded because it calls `requireAdmin()`. Read that function and every branch through it.

### 2. Code review by bug class

Work through `references/code-review.md` class by class against the entry-point map. Under about 5,000 lines of own code, do it inline. Larger codebases: one subagent per class group (`model: "opus"`), each gets the entry-point map and its section and returns candidates with `file:line` and the traced path.

### 3. Insecure defaults and sharp edges

`references/insecure-defaults.md`: sweep with the seed patterns plus patterns derived for the stack, then judge each candidate with the five steps there.

### 4. Automated scans

Run what is installed. If a tool is missing, offer `brew install semgrep gitleaks osv-scanner` and record the gap if the user declines.

```bash
OUT=<scratchpad>/security-audit-raw; mkdir -p "$OUT"
# --metrics=off on every semgrep call, the default sends telemetry
semgrep scan --metrics=off --config p/security-audit --config p/secrets --config p/owasp-top-ten \
  --config p/<language> [--config p/<framework>] [--config p/dockerfile] --json -o "$OUT/semgrep.json" <repo>
# --redact keeps found secrets out of the output
gitleaks dir <repo> --redact -f json -r "$OUT/gitleaks-dir.json"
gitleaks git <repo> --redact -f json -r "$OUT/gitleaks-git.json"
osv-scanner scan source -r <repo> --format json > "$OUT/osv.json"   # fallback: npm audit --json, pip-audit
```

- Packs per stack: TypeScript or JavaScript `p/typescript p/javascript p/react p/nextjs p/nodejs`, Python `p/python` plus `p/django`, `p/flask` or `p/fastapi`.
- Check the `errors` array and the scanned path count in the semgrep JSON. A pack that failed to load is a coverage gap.
- Supply chain beyond advisories (from Trail of Bits supply-chain-risk-auditor): is a lockfile committed and used by the build (`npm ci`, not `npm install`)? Which packages run install scripts (`hasInstallScript` in `package-lock.json`)? Do not estimate maintainer counts or abandonment from memory. Report them as not assessed.
- Every scanner hit is a candidate, not a finding. It goes through the gate like the rest.

### 5. Deployment and host

`references/live-and-host.md`, section Host. Read-only over SSH.

### 6. Live surface

Run `scripts/live_probe.sh <base-url> <protected paths...>`, then the manual checks in `references/live-and-host.md`, section Live.

### 7. Integrations

For every connection to another system (incoming and outgoing webhooks, automation workflows, third-party APIs, mail):

- How does each side authenticate the other? Is the secret compared in constant time? Was it rotated after any leak?
- What can a caller holding the secret do, and what does the response return? A webhook that returns CRM data to anyone with a leaked secret is a data source.
- Which credential does the integration use, with which scope? Is it the narrowest one?
- Which personal data leaves the system, to whom? Is that covered by the record of processing activities?
- Mail: SPF, DKIM and DMARC for the sender domain (`dig +short txt <domain>`, `dig +short txt _dmarc.<domain>`). No user-controlled HTML in mails. Links point to the real domain.

### 8. Verify

Run every candidate through `references/verification-gate.md`. Restate all claims first, many collapse right there. For each Critical or High candidate, a fresh subagent (`model: "opus"`) gets the claim and the code locations, not your reasoning. It starts from "refuted" and tries to disprove the claim. Keep the finding only if the refutation fails. Then look for chains: two Lows that together give an attacker something real.

### 9. Report

Fill `references/report-template.md`, including its line that the report is an automated audit for review by a security reviewer, not a penetration test. Verdict first: go, go with conditions, or no-go. In chat give the verdict, the count per severity, the top fixes and the report path. Offer to fix. Fix only after the user's OK, then rerun the checks that found the issue.

## Severity

| Severity | Meaning |
|---|---|
| Critical | An unauthenticated attacker reads or changes other people's data, takes over accounts or the server. Fix before go-live. |
| High | Same impact with a low bar: any logged-in user, a guessable value, a leaked secret that is still valid. Or a broken auth control. Fix before go-live. |
| Medium | Needs an unusual precondition, or the impact is limited (one record, a non-sensitive field, abuse such as mail bombing). Fix soon after go-live. |
| Low | Missing defense in depth (header, cookie flag, version leak) with no direct path to data. |
| Info | Hardening tip, no risk on its own. |

Models overrate severity. Rate by what the trace proves, not by the name of the bug class.

## Rationalizations to reject

| Thought | Reality |
|---|---|
| "It's behind a login" | Which login? Every partner or customer account is an attacker account. Check the object-level checks. |
| "Nobody knows the URL" | Certificate transparency logs publish new domains within minutes. |
| "The scanner found nothing" | Scanners do not find authorization bugs. Phase 2 does. |
| "It's an internal tool" | If it answers on the internet, it is not internal. |
| "The secret only lives in n8n" | List who can read it there and where else it was pasted. |
| "This pattern looks dangerous" | Trace it from an entry point or drop it. |
| "The framework handles that" | Name the guarantee and check that the code does not opt out of it. |
