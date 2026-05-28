# [FE-020] Bypass rate-limit in E2E suite

## Repo
frontend

## Type
chore

## Risk
low

> Test-infra fix. Production behaviour stays exactly the same.

## Priority
high

> Surfaced during FE-012's Next 16 bump. Tests don't fail because of
> Next 16; they fail because the FE-015 rate-limiter sees 18 e2e
> logins from the same `'unknown'` IP bucket and locks the 6th
> onward.

## Status
todo

## Background
FE-015 hardened the rate-limiter so that `X-Forwarded-For` headers are
ignored unless `TRUST_PROXY` is set. That made the limit truly
unbypassable from the network — but it also means that in our
Playwright suite (where every request goes through `pnpm dev` with
no proxy) every test buckets under `unknown`. After 5 login attempts
in the 10-minute window the 6th, 7th, …18th login spec all hit 429.

## Scope

**In scope:**
- New env flag `DISABLE_RATE_LIMIT` honoured by `lib/rate-limit.ts`.
  When set to `1` / `true` / `yes`, `checkRateLimit()` returns
  `{ ok: true }` immediately — buckets never fill.
- `playwright.config.ts` `webServer.env`:
  ```
  DISABLE_RATE_LIMIT: "1"
  ```
- Document in `.env.example` that the flag is a **dev/test-only**
  bypass. Add a guard log warning if it's seen in production.
- One new Vitest case in `tests/unit/rate-limit.test.ts` confirming
  the bypass branch is reachable only when the env is truthy.

**Out of scope:**
- Any change to the rate-limiter's prod logic
- A per-test rate-limit-bucket reset hook (the env bypass is simpler
  and doesn't require Playwright to know internal state)

## Acceptance Criteria

- [ ] `DISABLE_RATE_LIMIT=1` → all calls to `checkRateLimit()` return
      `{ ok: true }` regardless of count
- [ ] `DISABLE_RATE_LIMIT` unset / `0` → existing FE-015 behaviour
      unchanged (5/10min/IP)
- [ ] Playwright webServer launches with `DISABLE_RATE_LIMIT=1`
- [ ] `pnpm test:e2e` runs end-to-end **green** (18/18 or whatever
      the current spec count is — verify before/after)
- [ ] `pnpm test` (Vitest) — all green, the new bypass case included
- [ ] Production unaffected (no env set → no behavioural change,
      verified by the FE-015 attack-simulation test still passing)
- [ ] `.env.example` warns "dev/test only"; ideally a `console.warn`
      fires if both `NODE_ENV === "production"` and the bypass is on
