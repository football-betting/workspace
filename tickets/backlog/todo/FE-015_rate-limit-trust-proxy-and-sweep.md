# [FE-015] Harden rate-limiter against X-Forwarded-For spoofing + add eviction sweep

## Repo
frontend

## Type
chore

## Risk
medium

> Rate-limit is currently bypassable; brute-force of login is
> effectively unlimited. Flag for any public deploy.

## Priority
high

## Background
Audit finding M-3 (2026-05-28). `frontend/lib/rate-limit.ts:35-43`
`getClientIp` trusts `x-forwarded-for` unconditionally. An attacker
can rotate the header per request and get a fresh bucket each time —
the 5/10min limit becomes infinite. Plus the bucket Map grows
unboundedly (entries only cleared lazily on next hit for the same key).

## Scope

- Add `TRUST_PROXY` env var; only honor `x-forwarded-for` when set
  to a truthy value. Otherwise fall back to the socket address
  (`request.headers.get("x-real-ip")` if available, else a stable
  "unknown" bucket — better than per-request unique bucket)
- Add an eviction sweep: either an `setInterval` (with `unref()`),
  a hard cap on the Map size + LRU eviction, or use `lru-cache`
  (already in the dependency tree transitively — verify before adding)
- Document `TRUST_PROXY` in `.env.example`

## Acceptance Criteria

- [ ] `TRUST_PROXY=1` mode: `X-Forwarded-For` is honored (existing behavior)
- [ ] `TRUST_PROXY` unset/`0`: header ignored; rate-limit bucket
      keyed on socket addr or stable fallback
- [ ] Bucket Map size cannot grow without bound — either capped or
      swept on a schedule
- [ ] Existing FE-002 rate-limit tests still green
- [ ] Manual: 100 rapid login attempts from one socket address +
      randomised `X-Forwarded-For` → after the 5th, all return 429
      (when `TRUST_PROXY` unset)
