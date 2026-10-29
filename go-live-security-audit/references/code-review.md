# Code review by bug class

Start from the entry-point map of phase 1. For each class: what to look for and how to confirm it. Cite `file:line` for every claim.

## A. Authentication

- **Login paths:** provider config, callback, what identifies the user (which claim, is it verified), account linking between providers (Auth.js `allowDangerousEmailAccountLinking`), who may log in. The allowlist must be checked server side on every request, not only at sign-in.
- **Sessions:** JWT or database. Where does the signing secret come from, is there a fallback? Lifetime? What sits in the token, and is the role or tenant read from it (stale after removal) or reloaded from the database?
- **Magic links, OTPs, reset tokens:** entropy, single use, expiry, bound to the address, rate limit per address and per IP. Mail scanners prefetch links, a confirm page stops them from burning the token. Different responses for known and unknown addresses enable enumeration.
- **Removal and logout:** does a removed user or tenant lose access immediately, including open sessions?
- **Test or dev logins:** how are they gated in production? Can one env var turn them on?
- **Auth checklist (Trail of Bits sharp-edges):** constant-time comparison of secrets, empty values rejected, uniform errors, rate limits on every auth endpoint, central authorization with deny by default.

## B. Authorization and tenant isolation

Highest yield class. Most real leaks in small apps live here.

- Every entry point that takes an ID (path parameter, form field, server action argument): is the object loaded scoped to the caller (`where: { id, tenantId: session.tenantId }`), loaded by ID and checked afterwards, or not checked at all?
- Role checks run server side in every action, not only in the page that renders the button. In Next.js a server action is a public POST endpoint. Anyone who has the action ID can call it with any arguments, so each action checks auth itself.
- Middleware is not an auth boundary. Next.js CVE-2025-29927 skipped middleware via the `x-middleware-subrequest` header (fixed in 12.3.5, 13.5.9, 14.2.25, 15.2.3). Check the version, and check that pages and actions verify again.
- Field level: can a normal user set fields only admins should set (status, owner, tenant ID, dates, amounts)? Look for mass assignment, form data or JSON spread straight into an ORM `create` or `update`.
- Lists, exports, searches and counts filter by tenant. Aggregates leak too.
- Admin checks: how is the admin list compared (case, whitespace, empty entries)? Can a user change their own email to an admin address?

## C. Injection

- SQL: raw queries (`$queryRawUnsafe`, string concatenation, f-strings). Parameterized ORM calls are fine.
- Command execution, `eval`, `new Function`, server-side template rendering of user input.
- XSS: `dangerouslySetInnerHTML`, `innerHTML`, user input in `href` (`javascript:`), markdown rendering, user input in HTML mails (escape it), CSV exports opened in Excel (formula injection with `=`, `+`, `-`, `@`).
- Mail header injection: CR or LF in subject, from name or reply-to.
- SSRF: the server fetches a URL derived from user input (website field, webhook URL, avatar URL, PDF renderer).
- Path traversal: file reads or writes built from user input.

## D. Request integrity

- CSRF: cookie sessions plus state-changing GET requests? Next.js server actions compare Origin with Host. Check that `serverActions.allowedOrigins` was not widened. Auth.js POST routes carry their own CSRF token.
- Open redirect: `callbackUrl`, `next`, `redirect`, `returnTo` parameters. The Auth.js default redirect callback allows the same origin only. Custom callbacks may widen it.
- CORS: `Access-Control-Allow-Origin` reflecting the request origin together with credentials.

## E. Abuse and availability

- Endpoints that send mail, call paid APIs or write to third-party systems: rate limit? Can an anonymous user make the system mail arbitrary addresses (mail bombing, sender reputation)?
- Unbounded input: request body size, text fields stored as is, missing pagination limits.
- ReDoS: nested quantifiers (`(a+)+`, `(.*)*`) in regexes that run on user input.

## F. Data exposure

- What the server sends to the client. Next.js serializes every prop passed to a client component, including fields the UI never shows. Check what each `select` or `include` returns.
- Error messages and stack traces in responses. Is the production build running in production mode?
- Logs: personal data or secrets in `console.log`. Where do logs go, who reads them, how long are they kept?
- Source maps in production (`productionBrowserSourceMaps`), `NEXT_PUBLIC_*` variables (all of them ship to the browser).
- IDs: cuid or uuid make guessing hard but are not access control. Sequential IDs plus a missing check means full enumeration.

## G. Business logic

- Take the rules from the spec (CLAUDE.md, product docs, tickets). Can a user bypass one by calling actions out of order, twice, concurrently, or with edited values? Typical: accepting twice, repeating an extension request, dates or amounts set by the client.
- State machines: is every allowed transition checked server side?
- Writes to external systems (CRM, billing): who can trigger them, and with which data?

## H. JavaScript and TypeScript sharp edges

From Trail of Bits sharp-edges, `lang-javascript.md`:

| Pattern | Risk |
|---|---|
| `==` instead of `===` on roles or tokens | Type coercion bypass |
| `obj[userKey] = ...`, deep merge of user JSON | Prototype pollution |
| Nested quantifiers in regex on user input | ReDoS |
| Missing `await` before a validation or auth call | The check runs after the action, or never |
| `as Type` on request data instead of runtime validation (zod, valibot) | Unchecked shape reaches the database |
| `eval(`, `new Function(`, `setTimeout(string` | Code execution |
| `parseInt(x)` without radix, `Number("")` is `0` | Parsing surprises in limits and IDs |
| `"" ` in a list split from env (`"a,b,".split(",")`) | Empty entry matches empty values |

## Other stacks

- Python: `pickle`, `yaml.load` without SafeLoader, f-string SQL, Jinja `autoescape=False`, `DEBUG=True`, `requests(..., verify=False)`.
- Language references for C, Go, Rust, Java, Kotlin, C#, PHP, Ruby, Swift: https://github.com/trailofbits/skills/tree/main/plugins/sharp-edges/skills/sharp-edges/references
