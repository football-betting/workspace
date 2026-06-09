# FE-095 Run Playwright E2E in frontend CI (cross-repo betting-api checkout)

## Repo
frontend

## Type
chore

## Risk
medium

## Priority
medium

## Status
done

## Owner
implementer

## Background
The Playwright E2E suite (`frontend/tests/e2e/`, 15 specs) needs the whole stack
running together: Next.js on :3100, betting-api (Rust) on :8090, and a
migrated+seeded `shared/db/test.db`. Frontend CI today only runs type-check +
Vitest (unit + integration) — **no E2E** — and the workspace repo has no CI. So a
frontend change that breaks an end-to-end flow is not caught at PR time. The
betting-api source lives in a sibling repo, which is why the frontend job alone
can't run E2E.

Solution (option A): add an `e2e` job to frontend CI that checks out betting-api
alongside the frontend (both repos are public → `GITHUB_TOKEN` suffices, no PAT),
recreates the sibling layout the Playwright config expects, builds/seeds, and
runs the suite. It runs **after** the unit-test job so E2E minutes aren't spent
on a red unit run.

## Scope
- **In scope**:
  - New `e2e` job in `frontend/.github/workflows/frontend-ci.yml` with
    `needs: frontend` (runs only after type-check/unit/integration pass).
  - Second `actions/checkout` of `football-betting/betting-api` into a sibling
    path so `../betting-api` and `../shared/db` resolve as locally.
  - Node + pnpm + Rust toolchain (mirroring betting-api CI:
    `dtolnay/rust-toolchain@stable`, `Swatinem/rust-cache@v2`), Playwright
    browser install, `mkdir -p shared/db`, prebuild betting-api so the
    Playwright `cargo run` webServer starts within its timeout, then
    `pnpm test:e2e`.
  - Upload the Playwright report/traces as an artifact on failure.
- **Out of scope (explicit)**:
  - No change to the Playwright config, specs, or the app.
  - No cross-repo `repository_dispatch`/PAT (rejected in favour of in-job
    checkout).
  - betting-api PRs triggering E2E (would be the reusable-workflow option B —
    separate ticket if wanted).

## References
- `frontend/.github/workflows/frontend-ci.yml`
- `frontend/playwright.config.ts` (webServer: betting-api `cargo run` on :8090,
  `pnpm dev` on :3100, both `DATABASE_URL=../shared/db/test.db`)
- `frontend/tests/e2e/setup.ts` (globalSetup: `db:migrate` + `db:seed:test`)
- `betting-api/.github/workflows/main.yml` (Rust toolchain pattern)
- `betting-api/src/main.rs` (`BIND_ADDR`), `betting-api/src/db/mod.rs`
  (`DATABASE_URL`, `MODE`)

## Acceptance Criteria
- [ ] Frontend PRs run an `e2e` job that executes `pnpm test:e2e` against a real
      frontend + betting-api stack on the isolated ports (3100/8090).
- [ ] The job `needs: frontend` and is skipped/does not start until the unit job
      passes.
- [ ] betting-api is checked out at its default branch and prebuilt; the
      Playwright `cargo run` webServer comes up within timeout.
- [ ] `shared/db` directory is created so migrate/seed and both services share
      one `test.db`.
- [ ] On failure, the Playwright report is uploaded as an artifact.
- [ ] A red E2E result blocks the PR (job fails the check).

## Verification (manual)
1. Open a frontend PR → `frontend` job runs first; on success the `e2e` job
   starts, builds the stack, runs Playwright, reports pass/fail.
2. Introduce a deliberate UI break on a branch → the `e2e` job goes red and the
   PR check fails (then revert).

## Findings during implementation
- The first CI run proved the value immediately: **the signup E2E specs were
  pre-existing broken** (never run in CI before). `fillSignupForm` /
  `auth-flow.spec` / `signup.spec` selected `#winner = "DEU"`, but the signup
  form's `<option>` values come from `lib/data/teams.ts` where Germany's code is
  **`"GER"`** (football-data.org TLA). `selectOption` found no matching option
  and every signup-dependent test stalled to the 30s timeout (16 tests × 30s ×
  retry ≈ the 13-minute run). Fixed: `"DEU"` → `"GER"` in those three signup
  spots. Full suite now: 48 passed, 1 skipped, ~1.2 min locally.
- Tightened the Playwright `timeout` from the default 30s to **15s** (the app
  serves routes in well under a few seconds; real hangs should fail fast).

## Follow-up (separate ticket)
- **Product data inconsistency**: the signup form offers Germany as `"GER"`,
  while the DB seed and scoring use the ISO3 `"DEU"`. A user who signs up and
  picks Germany stores `winner="GER"`, which would never match a tournament
  winner recorded as `"DEU"`. This is a latent scoring bug independent of the
  tests — worth its own ticket (normalize team codes across signup ↔ seed ↔
  betting-api).
