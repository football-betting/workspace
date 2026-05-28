# FE-002 — Login + Signup with security hardening

**Status:** done
**Merged:** 2026-05-28
**PR:** [football-betting/frontend#2](https://github.com/football-betting/frontend/pull/2) (squash → `fb285a8`)
**Branch:** `feat/fe-002-login-signup` (deleted post-merge)

## What was done

Login + signup pages, three API route handlers, Zod validation, an
in-memory rate-limiter, and the full security hardening promised by the
ticket — explicit Argon2id parameters, generic login error with timing
parity, POST-only logout, password ≥8 + Zod email format, 5/10-min IP
rate-limit per bucket.

## Files changed

### `frontend/` (new)
- `app/(auth)/login/page.tsx` (~70 LOC) + `login-form.tsx` (~129 LOC, Client)
- `app/(auth)/signup/page.tsx` (~45 LOC) + `signup-form.tsx` (~323 LOC, Client)
- `app/api/auth/login/route.ts` (~94 LOC) — dummy-hash Argon2id verify
  on user-not-found for timing parity; generic 400 with identical body
  for both failure branches
- `app/api/auth/logout/route.ts` (~24 LOC) — POST 302 → `/login`
  (idempotent); GET 405 with `Allow: POST`
- `app/api/user/route.ts` (~121 LOC) — signup; explicit Argon2id
  (`memorySize: 19456, iterations: 2, tagLength: 32, parallelism: 1`)
- `lib/validation/auth.ts` (~38 LOC) — Zod `loginSchema` + `signupSchema`
- `lib/rate-limit.ts` (~45 LOC) — in-memory limiter, bucketed by `${bucket}:${ip}`
- `lib/data/teams.ts` (~35 LOC) — 24 UEFA team constants (ISO3)
- `lib/user.ts` (~25 LOC) — `getUserByEmail`, `createUser`
- `lib/session.ts` (~29 LOC) — `getCurrentSession` (React `cache()`-wrapped)

### `frontend/` (modified)
- `lib/db.ts` (+26/-6) — eager `new Database(...)` swapped for a lazy
  Proxy. Same Drizzle export contract; opens the connection on first
  property access instead of at module load. **Why this was needed:**
  `next build`'s "Collecting page data" step eagerly imports route
  modules, which transitively imported `db` and tried to open
  `../shared/db/database.db` before the file existed. The Proxy is
  fully API-compatible — Drizzle method chains and `db.query.*` work
  unchanged.
- `package.json`, `pnpm-lock.yaml` — `zod ^4.4.3`

## Quality gates

| Gate | Result |
|---|---|
| `pnpm exec tsc --noEmit` | ✅ clean |
| `pnpm build` | ✅ successful (9 static + 3 dynamic routes) |
| `grep -rn "<svg" app/ lib/` | ✅ 0 matches |
| `grep -rn "dangerouslySetInnerHTML" app/ lib/` | ✅ 0 matches |
| Forbidden icon-lib grep | ✅ 0 matches |
| `any` / `as any` / `@ts-ignore` audit | ✅ none |

## Reviewer verdict — APPROVE WITH MINOR NOTES

**Auth-boundary deep check (medium-risk gate):**
- Disclosure parity ✅ — user-not-found branch runs full dummy-hash
  Argon2id verify; both branches return identical `400 {"error":"Email or password incorrect."}`;
  ~2 ms timing delta between branches
- Cookie flags ✅ — Lucia defaults (`httpOnly: true`, `sameSite: 'lax'`);
  `secure: true` in prod
- CSRF coverage ✅ — middleware matcher covers `/api/*`; no new
  `RUST_APPLICATION` bypass
- Rate-limit correctness ✅ — 5 allowed, 6th 429 with `Retry-After`,
  per-`bucket:ip` keyed (login and signup buckets independent)
- Argon2id params ✅ — explicit OWASP 2024 in both routes and the
  dummy-hash
- Password leak audit ✅ — never logged, never returned

**Non-blocking observations carried forward:**

1. **Rate-limiter eviction sweep missing.** Entries past `resetAt`
   are only cleared lazily on next access. Memory growth is bounded by
   unique IPs, but worth a sweep for production. Track in future
   security/FE-008 follow-up.
2. **`Maintz` typo lives on** in `displayDepartment`. FE-001 decision
   driven by spec §16 "schema 1:1 with Astro" — deferred tech-debt.
   Reviewer flagged for visibility; not a blocker.
3. **No automated tests for new routes.** AC did not require them.
   FE-010 (Tests) will cover happy path, error parity, rate-limit,
   and disclosure parity once it lands.
4. **`lib/db.ts` change is in this commit** with rationale documented
   in the commit message — not silently attached to FE-001. Reviewer
   confirmed API-compatibility and build necessity.

## Decisions worth noting

1. **Form transport: Client-Component `fetch` POST to route handlers.**
   Ticket explicitly listed three route handlers, so Server Actions
   ruled out. Native HTML form post would show raw JSON on error.
   The tiny Client Components add `aria-live` inline errors without
   markup bloat (Material Symbols icons stay as `<span>`s).
2. **Argon2id timing parity:** user-not-found runs the real verify
   against a precomputed dummy hash that uses the exact same Argon2id
   parameters. Same work factor, same memory cost.
3. **Rate-limit keying:** `${bucket}:${ip}` — login and signup counts
   are independent. One IP can attempt 5 logins + 5 signups before
   either tips into 429.
4. **`lib/db.ts` lazy Proxy:** smallest possible change to keep the
   FE-001 export contract while fixing the build failure. Considered
   `dynamic = "force-dynamic"` per-route but that's invasive and
   doesn't solve the underlying eager-eval problem.

## Unblocks

- **FE-007** Demo-data seed — can now log in as `me@dev.local` once
  the seed runs
- **FE-003** Dashboard — `getCurrentSession()` + `<Layout>` Server
  Component pattern established
- **FE-009** Security audit — most auth-boundary checks already passed
  on this ticket; FE-009 will re-verify against the final assembled app
