# FE-009 — Security audit report

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#12](https://github.com/football-betting/frontend/pull/12) (squash → `4757c1a`)

## Summary
28 items audited: **24 ✅ verified**, **2 🔧 fixed**, **2 📌 follow-ups filed**.

## ✅ Verified (no action)

### Auth boundaries
- `app/(app)/**` gated by `app/(app)/layout.tsx` `getCurrentSession()` + `redirect("/login")` (FE-011)
- `/api/**` mutating routes call `getCurrentSession()` first
- Generic login error with timing parity via dummy-hash verify (FE-002)

### CSRF
- `verifyRequestOrigin` enforced for every non-GET request except `/api/match/import` (which is x-api-key-gated, FE-008)
- POST-only logout — GET → 405 `Allow: POST` (FE-002)
- SameSite=lax cookie provides second layer

### Cookies
- `httpOnly: true`, `sameSite: 'lax'`, `secure` in prod (Lucia defaults + FE-001 config)
- No `NEXT_PUBLIC_…` secrets — `git grep` clean
- No cookie substitutes for server-side session validation

### Input validation
- Zod on every API handler (login, signup, tip, match-import)
- Numeric bounds: tip 0-20, IDs positive integers via regex + `Number.isSafeInteger`
- Page params regex-validated

### Argon2id parameters
- `memorySize: 19456, iterations: 2, tagLength: 32, parallelism: 1` in login + signup routes + dummy hash

### Rate limits
- POST `/api/auth/login` and POST `/api/user`: 5 attempts / 10 min per IP with `Retry-After` (FE-002)
- POST `/api/tip/[matchId]` not pre-auth enumerable (session required first)

### Rust API trust
- `MATCH_IMPORT_API_KEY` documented in `.env.example`, read via `process.env` with empty-string guard (FE-008)

### Server secrets
- `.env` gitignored; only `.env.example` committed with placeholders
- `git grep` for committed secrets: zero matches

## 🔧 Fixed in this PR

### `next.config.ts`
- `poweredByHeader: false` — stops advertising `X-Powered-By: Next.js`

### `middleware.ts`
- New `withSecurityHeaders()` helper applied to both success + 403 CSRF-reject paths:
  - `Content-Security-Policy` — `default-src 'self'`; script-src `'self' 'unsafe-inline'` (`'unsafe-eval'` only in dev for HMR); style-src `'self' 'unsafe-inline' https://fonts.googleapis.com`; font-src `'self' https://fonts.gstatic.com` (Material Symbols); img-src `'self' data:`; `frame-ancestors 'none'`; `form-action 'self'`; `object-src 'none'`
  - `X-Frame-Options: DENY`
  - `Referrer-Policy: strict-origin-when-cross-origin`
  - `Permissions-Policy: camera=(), microphone=(), geolocation=()`
  - `X-Content-Type-Options: nosniff`
- Verified via `curl -si http://localhost:3000/login`

## 📌 Follow-up tickets opened

- **FE-012** — bump `next` to `>=15.5.16` and `drizzle-orm` to the patched line. `pnpm audit --prod` reports 28 advisories against `next@15.0.4` and `drizzle-orm@0.36.4`, including **two critical** (CVE-2025-29927 Middleware auth bypass; RCE in React flight protocol) and **nine high**. **Must clear before public deploy.**
- **FE-013** — Zod-validate Rust API responses in `lib/api.ts` `fetchApi<T>`. Today the function casts `await res.json()` to `T` with no runtime check; dashboard/ranking/profile/match-detail all blind-trust the shape. Add an optional `schema?: ZodSchema<T>` argument and treat `safeParse` failures as offline.

## Quality gates
- `pnpm exec tsc --noEmit` clean
- `pnpm build` clean
- Headers smoke-tested via curl — every baseline header lands
- Icon greps still 0 — no regression
- No new `any` introduced
