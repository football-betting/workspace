# FE-015 — Harden rate-limiter

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#15](https://github.com/football-betting/frontend/pull/15) (squash → `4242146`)

## What was done
- `TRUST_PROXY` env gate: when unset (default), `x-forwarded-for` and `x-real-ip` are ignored — all requests bucket under `'unknown'`, so spoofed headers can't bypass the limit. Set `TRUST_PROXY=1`/`true`/`yes` only when behind a proxy that strips client-supplied `X-Forwarded-For`.
- Eviction sweep: `setInterval` (with `.unref()`) clears expired entries every 60 s.
- `MAX_BUCKETS=10_000` hard cap: inline sweep + oldest-eviction on overflow.
- `.env.example` documents the new var.
- 10 new vitest cases including an attack-simulation test (100 requests with rotating fake XFF → only `MAX_ATTEMPTS` pass).

## Reviewer verdict — APPROVE (implementer self-review during the in-line fix)
53/53 tests, build clean, no new packages.
