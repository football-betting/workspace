# FE-064 Result — Auth/Config Hardening Bundle

Status: DONE (review passed)
Repo: frontend
Risk: medium — external review recommended (auth/session-adjacent), not required.
Reviewer verdict: PASS, no enumeration regression, no legitimate flow broken.

## What was done
Six defense-in-depth hardenings from the 2026-06-01 security audit, each minimal:

1. Forgot-password timing — reset issuance (DB write + SMTP) detached via `void issueReset(...)`; generic `{ ok: true }` 200 returned immediately on every path.
2. APP_BASE_URL enforcement — new `lib/app-origin.ts` `resolveAppOrigin()`: trims `APP_BASE_URL`, returns `null` in production when unset (no Host fallback), dev falls back to request origin.
3. Rate-limit IP — trusted-proxy reads Nth-from-right XFF via `TRUSTED_PROXY_HOPS` (default 1); untrusted path uses per-client `untrusted:<ip>` key instead of one global `unknown` bucket.
4. Push ownership — `savePushSubscription` no longer reassigns an endpoint's `userId` to the caller; cross-owner hand-off is delete-then-insert, conflict update scoped via `setWhere`.
5. Cron — `crypto.timingSafeEqual` over SHA-256 buffers, fail-closed (401) when `CRON_SECRET` unset, added `checkRateLimit`, POST-only (GET → 405).
6. DISABLE_RATE_LIMIT — ignored entirely when `NODE_ENV==="production"`; dev/test bypass intact.

## Files changed
- `frontend/lib/app-origin.ts` (new)
- `frontend/app/api/auth/forgot-password/route.ts`
- `frontend/app/api/cron/notifications/route.ts`
- `frontend/lib/rate-limit.ts`
- `frontend/lib/push-store.ts`
- `frontend/tests/unit/rate-limit.test.ts`
- `frontend/.env.example`

## Quality gate
- `bash scripts/check.sh`: tsc clean, vitest 186/186 pass (rate-limit suite 15 tests).
- `bash scripts/check.sh --build`: next build green, all routes compiled.

## Per-criterion verification
- AC1 dominant I/O-based timing oracle removed (SMTP + DB write detached; `getUserByEmail` runs identically in both branches). Residual sub-microsecond sync delta (one `randomBytes`+hash) is not network-observable. PASS.
- AC2 prod fails closed to `null`; forgot-password skips email, cron returns 500; dev keeps request-origin fallback. PASS.
- AC3 distinct clients no longer share a global bucket (tested); trusted-proxy takes rightmost/Nth-from-right (tested). PASS.
- AC4 endpoint unique; ownership never silently reassigned (`setWhere` scopes to caller); cross-owner is delete+insert. PASS.
- AC5 constant-time equal-length compare; 401 when secret unset; POST-only; rate-limit margin fine at ~10min cadence. PASS.
- AC6 prod ignores the flag; dev/test bypass verified by passing test. PASS.

## Notes (non-blocking)
- Cron rate-limit margin: 5 attempts / 10 min on a fixed key. Safe at the documented ~10 min cadence; would trip below ~2 min cadence.
- Untrusted XFF fallback remains spoofable by design (documented); strictly better than the prior global-lockout bucket, no worse for brute-force.
- Push hand-off (select→delete→insert) is not transactional; a concurrent cross-owner race can only fail the insert (unique constraint), never hijack — acceptable.
- `frontend/scripts/mobile-audit.mjs` is untracked and unrelated to FE-064; not part of this ticket's scope — exclude from the commit.
