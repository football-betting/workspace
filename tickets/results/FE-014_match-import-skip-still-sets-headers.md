# FE-014 — Apply security headers on /api/match/import

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#14](https://github.com/football-betting/frontend/pull/14) (squash → `259f4b8`)

## What was done
One-line wrap of the middleware match-import pass-through through `withSecurityHeaders()`. CSP, X-Frame-Options, Referrer-Policy, Permissions-Policy, X-Content-Type-Options now land on every response from `/api/match/import`. CSRF origin-check still skipped (FE-008 x-api-key auth unchanged).
