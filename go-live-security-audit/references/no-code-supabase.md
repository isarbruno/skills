# No-code / managed-backend apps (Lovable, Bolt, v0, Replit; Supabase or Firebase)

Colleagues increasingly ship apps built by an AI builder. These share a shape that changes how you audit them:

- There is usually **no source repo** to read. You audit black-box: the live URL and the client JS bundle.
- The frontend talks **straight to a managed backend** (most often Supabase, sometimes Firebase) using a **public client key that ships in the bundle**. That key is public by design. Finding it is not a finding.
- There is little or no custom server code. **The backend's row-level rules are the entire security model.** The one place almost every one of these apps goes wrong is authorization: who may read or write which rows.

Anonymous access being locked down tells you almost nothing. The decisive question is what a **logged-in** user can reach, because signup is often open to the world. "Anon reads nothing" plus "anyone can sign up" plus "any logged-in user reads everything" is the standard critical finding here.

## Recipe (Supabase; Firebase notes at the end)

All steps are read-only except step 5, which needs the user's OK. Keep to one request per second. Mask PII and secrets in your output.

### 1. Find the backend in the bundle

Fetch `/` and the main `/assets/*.js`. From the JS:

- Supabase project URL and anon key: `grep -oE 'https://[a-z0-9]{20}\.supabase\.co'` and `grep -oE 'eyJhbGciOiJ[A-Za-z0-9_.-]{20,}'` (a JWT). Decode the key payload: `role` should be `anon`, `ref` is the project id.
- Surface map: `.from("<table>")`, `.rpc("<fn>")`, `storage.from("<bucket>")`, `functions.invoke("<edge-fn>")`. This is your entry-point list. Note which edge functions and RPCs look like admin or write actions.

### 2. Read the auth config (the single most important request)

```
GET https://<ref>.supabase.co/auth/v1/settings   (header: apikey: <anon key>)
```

- `disable_signup: false` → **anyone on the internet can create an account.** On an internal tool this is already a finding.
- `mailer_autoconfirm: true` → **no email verification.** Signup returns an active session immediately, with any address. Combined with open signup, every outsider is an authenticated user.
- `external.*` → which OAuth/SSO providers are on. An internal tool should be SSO-only or domain-restricted.

### 3. Test RLS as an anonymous caller

For each table: `GET /rest/v1/<table>?select=*&limit=1` with the anon key. Add `Prefer: count=exact` + `Range: 0-0` to read the total from the `Content-Range` header.

- `200` with `[]` / count `*/0` → RLS blocks anon (expected, good).
- `200` with rows → the table is world-readable. Finding.

Do the same for RPCs (`POST /rest/v1/rpc/<fn>` with `{}`) and storage bucket listing.

### 4. The decisive test: RLS as an authenticated outsider

If signup is open, this is where the real findings are. **Creating an account is a write to their auth system, so get the user's explicit OK first.** Use the user's own `+alias` (e.g. `name+sectest-<ts>@company.tld`). With autoconfirm on, signup returns a session token directly, no mailbox needed:

```
POST /auth/v1/signup  (apikey header)  body {"email","password"}
```

Decode the returned `access_token` (expect `role: authenticated`). Re-run every read from step 3 with `Authorization: Bearer <that token>`. Now you learn what any stranger who signs up can read. The classic Lovable mistake is a policy written as `USING (auth.role() = 'authenticated')` or `USING (true)` instead of `USING (auth.uid() = user_id)`, which exposes the whole table to every logged-in user.

### 5. Enumerate hidden tables

Tables the client never touches (token stores, integration tables) do not appear in the bundle but still answer the API. Probe likely names as the authenticated account: `linkedin_tokens`, `*_accounts`, `*_connections`, `user_integrations`, `oauth_tokens`, `credentials`, and so on. `404` = no such table, `200 []` = exists and RLS blocks you (good), `200` rows = exposed.

### 6. Edge functions and RPCs are the server code

Test the auth posture harmlessly, never the destructive action:

- No token → expect `401`.
- Authenticated-outsider token + empty or minimal body → read the validation/permission error. This tells you whether the function even checks the caller.
- **Does the function trust a client-supplied identity?** Probe with the identity param (`user_id`, `author_id`, `on_behalf_of`, ...) aimed at a **non-existent** id (the zero-UUID `00000000-0000-0000-0000-000000000000`), so no real user can be affected, and compare the error to the baseline. A function that acts on a client-supplied id instead of the JWT is a broken-access-control finding.
- **Never** complete an outward or destructive action on real data: no real posts to LinkedIn/X, no emails, and never call an `admin-manage-user` / delete / reset function with a payload that could act. Those need source review, not a live probe.

### 7. Clean up

You cannot delete an auth user without the `service_role` key (which a read-only audit never uses). Signup often fires a trigger that also creates `profiles` / `user_roles` rows. Tell the user to delete the test account **and** those rows from the dashboard, and give them the account email and user id.

## The findings you will almost always be checking for

1. Open signup (+ autoconfirm) on an internal tool → any outsider becomes an authenticated user. High, often Critical in combination with 2.
2. RLS SELECT policies scoped to `authenticated` / `true` instead of the owner → any logged-in user reads all rows (all profiles, all activity, the full content set). Critical when it is personal data.
3. Writable `user_roles` (or similar) → a user makes themselves admin. Critical.
4. Edge function missing a server-side admin check → the UI hides the button, the endpoint does not. Potentially Critical; confirm in source, do not exploit.
5. Secrets in a client-readable table (an `app_settings`-style key/value store). Critical if a live token.
6. Over-broad write policies. You tested reads; confirm INSERT/UPDATE/DELETE are owner- or admin-scoped too.

## The fixes to hand back

- Signup: SSO only (the company IdP), or disable signup, or a trigger on `auth.users` that rejects non-company email domains. Turn off autoconfirm if email stays.
- An `is_admin()` SECURITY DEFINER helper, and owner-scoped SELECT policies (`auth.uid() = user_id OR is_admin()`).
- No write policies on role tables for `authenticated` / `anon`.
- Admin checks inside every admin edge function and `admin_*` RPC, read from the caller's JWT.
- Secrets only in Supabase secrets / function env vars, never in a table a client role can read.

## Firebase variant

Same idea, different surface. The security model is **Firestore / Storage security rules**. The red flags: `allow read, write: if true;` (fully open) or `if request.auth != null;` (any signed-in user, same mistake as the Supabase `authenticated` policy). Check the Firebase Auth settings for open signup, and whether rules scope documents to `request.auth.uid`. Firestore REST: `GET https://firestore.googleapis.com/v1/projects/<id>/databases/(default)/documents/<collection>`.
