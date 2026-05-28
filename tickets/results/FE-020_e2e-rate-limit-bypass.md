# FE-020 — Bypass rate-limit in E2E suite

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#23](https://github.com/football-betting/frontend/pull/23) (squash → `314aeeb`)

## What was done
- `lib/rate-limit.ts` honours `DISABLE_RATE_LIMIT=1` (dev/test only) — `checkRateLimit` returns ok immediately, bucket Map untouched
- `playwright.config.ts` webServer.env sets the flag
- `.env.example` documents the flag with dev/test-only warning
- `console.warn` fires once if the flag is on with `NODE_ENV=production`
- 2 new Vitest cases verify the bypass branch + that `0`/unset retains the FE-015 limit

## Quality gates
- vitest 77/77 (was 75, +2)
- playwright 17/18 (was 6/18 with FE-012 baseline)
- Remaining failure: pre-existing ranking spec when Rust API is offline (unrelated to FE-020)
- FE-015 attack-simulation still proves real-network limit holds
