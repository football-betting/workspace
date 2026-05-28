# [FE-009] Security audit pass over the completed frontend

## Repo
frontend

## Type
chore

## Risk
medium

> Final security gate before the rebuilt app goes anywhere near production.
> Findings here either get fixed in this ticket or filed as follow-ups.

## Priority
medium

> Bump to **high** before any deploy to a public host.

## Status
todo

## Owner
reviewer

## Background
FE-002 ships login/signup with rate-limit + password policy + generic
errors + Argon2id parameters. FE-008 fixes the match-import API key.
This ticket is the **last** ticket in the FE chain: a structured audit
of the assembled codebase to catch what individual tickets missed.

The audit is a checklist, not a refactor. Each item is either ✅ verified
or 🔧 fixed in this ticket. Anything larger gets a follow-up ticket.

## Scope

**In scope:**
- Read-and-verify pass over every route, API handler, middleware, and
  env touchpoint
- Small fixes that arise (missing headers, missing flags, missing checks)
- A short report at `tickets/results/FE-009_security-audit.md` listing
  every finding with status

**Out of scope (explicit):**
- Re-architecting auth or session handling
- Adding new features
- Penetration testing or external security audit
- Postgres migration or schema changes

## References

- `docs/FRONTEND_FUNKTIONS_SPEC.md` §19.1 (security recommendations)
- All FE-001…FE-008 tickets (verify their acceptance criteria are still
  satisfied in the final build)
- OWASP Cheat Sheet Series (for header hardening references)

## Acceptance Criteria — Audit Checklist

### Auth boundaries
- [ ] Every page under `app/(app)/**` (or whatever the protected segment
      is called) hits an auth check via middleware or layout guard
- [ ] Every `app/api/**` route handler that mutates data calls
      `getSession()` (or equivalent) before doing anything, unless it is
      an intentionally public endpoint (login, signup, match-import)
- [ ] Auth failure responses do not leak whether a user exists, what
      data was almost returned, or any internal state

### CSRF
- [ ] All POST forms (login, signup, logout, tip, … ) carry a CSRF token
      or are protected by SameSite cookies + Origin check; document which
      mechanism applies where
- [ ] `POST /api/match/import` is the only route allowed to skip the
      Origin check, and it is guarded by `x-api-key` instead

### Cookies
- [ ] Session cookie: `httpOnly: true`, `sameSite: 'lax'`,
      `secure: true` in production
- [ ] No `NEXT_PUBLIC_…` variable contains anything secret
- [ ] No cookie carries data that could substitute for a server-side
      session check

### HTTP headers (set in `middleware.ts` or `next.config.js`)
- [ ] `Content-Security-Policy` configured (at minimum, restrict
      `default-src`, `script-src`, `style-src`, `img-src`, `connect-src`
      to known origins)
- [ ] `X-Frame-Options: DENY` (or `frame-ancestors 'none'` via CSP)
- [ ] `Referrer-Policy: strict-origin-when-cross-origin`
- [ ] `Permissions-Policy` denies camera/microphone/geolocation
- [ ] No `Server`/`X-Powered-By` headers leaked

### Input validation
- [ ] Every API handler parses input via Zod (no direct
      `await req.json()` without a schema, no `formData.get(...)` without
      validation)
- [ ] Numeric inputs are bounded (`tip1`, `tip2` ∈ [0,20]; IDs are
      positive integers)
- [ ] String inputs have max length

### Argon2id parameters
- [ ] `memorySize: 19456`, `iterations: 2`, `tagLength: 32`,
      `parallelism: 1` — explicitly set in code, not relying on defaults

### Rate limits
- [ ] `POST /api/auth/login` rate-limited (per FE-002)
- [ ] `POST /api/user` rate-limited (per FE-002)
- [ ] `POST /api/tip/[matchId]` is **not** abusable as an enumeration
      oracle for valid match IDs (response shape identical for "not
      logged in" / "match not found" / "out of range")

### Rust API trust
- [ ] `MATCH_IMPORT_API_KEY` (FE-008) is set in every deployed env
      (dev, test, prod)
- [ ] No request body from the Rust API is trusted past a Zod schema
      (`fetchApi` results are validated before render)

### Dependency hygiene
- [ ] `pnpm audit --prod` is clean, or every remaining advisory is
      documented (id + severity + reason it does not apply)
- [ ] No package pinned to a major version known to be EOL

### Server secrets
- [ ] `.env` is gitignored; `.env.example` only contains placeholders
- [ ] No secret string appears in committed source (`git grep` for the
      common patterns: `password=`, `secret`, `api_key`)

## Verification (manual)

1. Walk the entire app logged out → every protected route redirects
   to `/login`
2. Walk it logged in → no errors, no unexpected data, no console warnings
3. `curl -I https://localhost:3000` → security headers visible in the
   response
4. Inspect a session cookie in DevTools → flags match the checklist
5. `pnpm audit` → matches the documented baseline
6. Submit the report at `tickets/results/FE-009_security-audit.md`
   listing each item as ✅ / 🔧 (fixed) / 📌 (follow-up filed)

## Notes

Depends on FE-001…FE-008. This is the last gate before FE-010 (tests)
runs against the final codebase.

Reviewer should approach this with the agent at `.claude/agents/reviewer.md`
(framework-aware checks for Next.js auth boundaries and the Rust
trust boundary).
