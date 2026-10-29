# Insecure defaults and sharp edges

From Trail of Bits insecure-defaults and sharp-edges.

Candidates come in two shapes, judged differently:

- **Configurable:** a lookup with a fallback. A bug only if the app runs with the fallback. `process.env.X || "dev"` runs. `process.env.X!` followed by a crash does not.
- **Unconditional:** no configuration involved, insecure as written. About half of all real findings. A missing env var is no reason to refute one.

## Sweep

Grep the seeds below, then derive patterns for the stack: the project's own config wrappers, framework keys, compose and Dockerfile syntax. Seeds are POSIX ERE. Never use `\s`, `\d` or `\b`, some grep builds silently match nothing with them. Exclude `node_modules`, build output and lockfiles. Sweeps collect, they do not judge.

| Category | Report when | Skip when | Seeds |
|---|---|---|---|
| Fallback secrets | A default used when the env var is absent feeds signing, encryption, session or token logic. | Random per-boot defaults. Values used only as cache keys or IDs. | `process\.env\.[A-Z_]+[[:space:]]*(\|\||\?\?)[[:space:]]*['"]`, `environ\.get\([^,]+,[[:space:]]*['"]`, `getenv\([^,]+,[[:space:]]*['"]`, `\$\{[A-Z_]+:-` |
| Default credentials | A credential literal a running deployment can authenticate with, including seeded accounts. | Accounts created disabled or with forced reset. Credentials in docs and test fixtures. | `(password\|passwd\|secret\|token\|api_?key)[[:space:]]*[:=][[:space:]]*['"][^'"]{4,}`, `admin123\|changeme\|password1` |
| Fail-open switches | The unconfigured value disables a security control. | The unconfigured value is the secure one. Flags never read at the enforcement point. | `(DISABLE\|SKIP\|BYPASS\|INSECURE\|DRY_RUN\|TEST\|DEBUG\|E2E)[A-Z_]*`, `NODE_ENV[[:space:]]*!==?` |
| Weak crypto | A broken or non-cryptographic primitive stands in for a security one: password hashing, token generation, signatures, secret comparison. | Checksums, ETags, cache keys, test vectors. | `Math\.random`, `md5\|sha1`, `createHash\(`, `rejectUnauthorized:[[:space:]]*false`, `verify=False`, `alg.*none` |
| Permissive access | Access goes to a party that should not have it, hardcoded or as the fallback. | Deliberate public endpoints with a stated reason. Local-only dev servers. | `Access-Control-Allow-Origin`, `origin:[[:space:]]*['"]\*`, `0o?6[0-9]6\|0o?777\|chmod`, `0\.0\.0\.0:`, `ports:` |
| Debug leakage | Internal detail reaches a response, an open port or a log a less privileged party reads. | Log verbosity only. Debug servers on loopback and off by default. | `stack\|traceback\|err\.message`, `console\.(log\|error)\(`, `productionBrowserSourceMaps`, `NEXT_PUBLIC_` |

## Judge each candidate

Start at "refuted" and stop at the first step that kills the candidate. An incomplete trace counts as refuted.

1. Is the file reachable in production? Tests, local scripts and code that is never deployed are not.
2. Is the insecure value the one that runs? Configurable: does the app fail secure when the var is unset? Unconditional: this step cannot refute it.
3. Is the value actually insecure? `md5` over a cache key is fine. Over a password it is not.
4. Does it reach a security decision? Cite the sink.
5. Does the deployment always supply the var? Check the server env by key name only, never print values. Set everywhere lowers the severity to Low (one config mistake away). Unknown counts as reachable.

## Sharp-edge probes

From Trail of Bits sharp-edges. For every security-relevant config value and parameter, ask what happens with:

- `0`, `""`, `null` or `undefined`, a negative number. Does a timeout of 0 mean "never expires"?
- A list split from env with a trailing comma or a space (`"a@x.com, b@x.com,"`). Does the empty entry match an empty value somewhere?
- Upper case or whitespace variants of an allowlisted value (emails, domains).
- A domain allowlist checked with `endsWith` (`evilexample.com` ends with `example.com`).
- Two settings that contradict each other. Which one wins?

Three adversaries: the scoundrel who controls input or config, the lazy developer who copies the first example, the confused developer who swaps two parameters. Is the easy path the secure one?
