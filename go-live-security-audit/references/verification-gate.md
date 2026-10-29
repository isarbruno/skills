# Verification gate

From Trail of Bits fp-check. Models are biased toward seeing bugs and overrating them. This gate decides what the report may call a finding.

## Step 0: restate the claim

For each candidate write:

- **Claim:** what exactly is wrong, in one sentence.
- **Root cause:** `file:line`.
- **Trigger:** the request or action that sets it off.
- **Attacker:** anonymous, logged-in user of role X, admin, someone with host access. What can that attacker already do without the bug?
- **Impact:** which data is read or changed, which account taken over, what it costs.

If the claim does not restate cleanly, drop it. Half of all false positives die here.

## Checklist

Apply every item to every candidate.

1. **Trace the full validation chain backwards:** middleware, layout, page, action, service, database constraint. A check anywhere on the path may already block it.
2. **Reachability:** which entry point from the phase 1 map leads here, with which role?
3. **Attacker control:** which part of the input does the attacker control? Server-set values, session data reloaded from the database and constants are not attacker input.
4. **Framework guarantees:** React escapes output, Prisma parameterizes, Next.js checks the Origin of server actions, Auth.js signs its own CSRF token. Do not report what the framework blocks, unless the code opts out.
5. **Test and dev paths:** if the code only runs in tests or locally, how is that gated in production? A gate that one env var can flip is a finding of its own.
6. **Real impact:** data read or changed, account taken over, money spent, mail sent in someone's name. Operational robustness alone is not a security finding.
7. **Defense in depth vs primary control:** a missing second layer is Low when the first layer holds.
8. **Environment:** does the deployed config, proxy, firewall or network block it entirely?

## Proof

Live systems get harmless proof only:

- A request that shows the missing check without changing data (for example reading an object of another tenant with a test account the user created).
- A local run against a local database, or a unit test that calls the action with the attacker's input.
- A code trace with `file:line` for every hop, when a run is not possible.

Never exploit production data, never write to production, never send mail to real people.

## Gates

| Gate | Pass | Fail |
|---|---|---|
| 1. Process | Steps above done, each with evidence | Steps skipped or without evidence |
| 2. Reachability | Attacker reaches the code from a real entry point | No path found |
| 3. Real impact | Concrete data, account or cost | Only robustness |
| 4. Proof | Harmless proof or a complete trace | Trace has gaps |
| 5. Preconditions | Realistic for the attacker named | Needs access that already gives the same impact |
| 6. Environment | Deployment does not block it | Deployment blocks it entirely |

Verdict format:

```
F-03 TRUE POSITIVE (High): partner can read other partners' deals via getDeal(id), src/lib/deals.ts:88
C-07 FALSE POSITIVE: Math.random in src/lib/ids.ts:12 only builds a CSS key. Gate 3 fails.
```

## Independent refuter (Critical and High)

Spawn a fresh subagent with `model: "opus"`. Give it the claim, the root cause location and the repo path. Do not give it your reasoning. Prompt:

> You are an application security engineer who reviews other people's findings for false positives. Your default verdict is REFUTED. Read the code at the given locations and everything that calls it. Try to show that an attacker with the stated role cannot trigger the claim, or that the impact is smaller than stated. Return REFUTED or CONFIRMED, the evidence with `file:line`, and the severity you would assign.

Keep the finding only on CONFIRMED. On a severity disagreement, take the lower one unless you can name the evidence the refuter missed.

## Red flags for false positives

- Reporting the validation code itself as the bug.
- Assuming network input reaches a sink without tracing it.
- Ignoring a check earlier in the call chain.
- Reporting test-only or local-only code as a production issue.
- Calling a race condition without showing two requests can interleave.
- Counting the same root cause twice under two bug classes.
