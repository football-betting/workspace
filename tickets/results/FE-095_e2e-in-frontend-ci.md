# FE-095 Result — Playwright E2E in frontend CI

## What was done

Added an `e2e` job to the frontend CI that runs the full Playwright suite
against a real stack (Next.js + betting-api + seeded test DB) at PR time, so a
frontend change that breaks an end-to-end flow is now caught. The job checks out
the betting-api repo alongside the frontend (both public → no PAT), recreates the
sibling layout, prebuilds betting-api, seeds `shared/db/test.db`, and runs the
suite. It `needs: frontend`, so it only starts after type-check/unit/integration
pass. No coverage is sent for E2E (black-box browser test); a failing E2E blocks
the PR.

## Surfaced + fixed a pre-existing bug

The very first CI run proved the point: the **signup E2E specs were broken and
had never run in CI**. The helpers selected `#winner = "DEU"`, but the signup
form's option values come from `lib/data/teams.ts` where Germany is `"GER"`
(football-data.org TLA). `selectOption` matched no option, so 16
signup-dependent tests each stalled to the 30s timeout (≈ the 13-minute first
run). Fixed `"DEU"` → `"GER"` in `helpers.ts`, `auth-flow.spec.ts`,
`signup.spec.ts`. Also tightened the Playwright `timeout` 30s → 15s (the app is
fast; hangs should fail quickly).

Result: full suite **48 passed, 1 skipped** locally (~1.2 min) and the CI `e2e`
job is green in **~3.6 min** (Playwright step ~2 min).

## Files changed (frontend, branch `fe-095-e2e-in-ci`)

- `.github/workflows/frontend-ci.yml` — new `e2e` job (cross-repo checkout,
  Rust + Node + pnpm, prebuild betting-api, `pnpm test:e2e`, report artifact)
- `tests/e2e/helpers.ts`, `tests/e2e/auth-flow.spec.ts`,
  `tests/e2e/signup.spec.ts` — team code `"DEU"` → `"GER"`
- `playwright.config.ts` — `timeout: 15_000`

## Verification

- CI on PR #111: `type-check · unit tests · coverage` SUCCESS, then
  `e2e (playwright, full stack)` SUCCESS (~3.6 min). codecov SUCCESS.
- Local full suite: 48 passed, 1 skipped (the production-only non-valantic
  email test), ~1.2 min.

## Follow-up

- **XR-009**: team-code inconsistency — signup form stores Germany as `"GER"`
  while seed/scoring use ISO3 `"DEU"`; a form-registered Germany pick would never
  match the tournament winner. Real scoring bug, separate ticket.
- Optional E2E speed-up via CI sharding (no per-user refactor needed) if the
  ~3.6 min ever becomes a bottleneck.
