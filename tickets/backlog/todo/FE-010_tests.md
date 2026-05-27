# [FE-010] Unit + E2E test suite running against the demo seed

## Repo
frontend

## Type
chore

## Risk
low

## Priority
high

> Regression safety net before the rebuild is anywhere near production.

## Status
todo

## Owner
implementer

## Background
The rebuilt frontend has six feature tickets, a security audit, and a
seeded demo dataset. Before any deploy, we need automated tests that
exercise the critical paths against the **same** seed every time
(FE-007), so a failing test means a real regression and not a data
quirk.

Two layers:
- **Vitest** for unit tests on pure logic (scoring, validation, helpers)
- **Playwright** for end-to-end flows in a real browser against a Next.js
  dev server pointed at `shared/db/test.db`

## Scope

**In scope:**
- Vitest setup (`vitest.config.ts`), test files under `tests/unit/**`
- Playwright setup (`playwright.config.ts`), test files under `tests/e2e/**`
- `package.json` scripts: `test`, `test:unit`, `test:e2e`,
  `test:e2e:headed` (for debugging)
- A `globalSetup` that runs `pnpm db:seed:test` against `shared/db/test.db`
  before the suite, ensuring a deterministic starting state
- `.env.test` documenting `DATABASE_URL=../shared/db/test.db` +
  `RUST_API_URL` + `MATCH_IMPORT_API_KEY`
- Test coverage for the cases listed below — enough to catch regressions,
  not a 100% coverage chase

**Out of scope (explicit):**
- CI workflow that runs the suite (separate DevOps ticket)
- Visual regression snapshots (Chromatic / Percy)
- Load / performance testing
- Tests against the real Rust services in prod (we stub or run them
  locally for E2E)
- 100% branch coverage targets — focus on critical paths

## References

- `docs/FRONTEND_FUNKTIONS_SPEC.md` §14 (test-behaviour spec from the
  legacy app — the cases marked there must remain green)
- `tickets/backlog/todo/FE-007_demo-data-seed.md` — the dataset every
  test relies on
- `em2024-frontend/tests/**` — original test files, useful as a
  reference for what was previously covered

## Acceptance Criteria

### Vitest (unit)

Pure-logic units under `lib/`:

- [ ] **Scoring**: `score(tip, match)` → returns 4 / 2 / 1 / 0 for each
      of the four canonical cases (exact / goal-diff / outcome / wrong),
      derived from concrete seed rows
- [ ] **Username truncation**: `abbreviateUsername(name)` → 26-char input
      returns 14 chars + `…`; 9-char input is unchanged
- [ ] **Date helpers**: `formatDate(ts)` returns `"Samstag, 31. Dezember
      2022"` for `new Date(2022,11,31).getTime()`; `extractTime(ts)`
      returns `"13:45"` for `new Date(2022,11,31,13,45)`
- [ ] **Tip eligibility**: `canEditTip(match, now)` returns true iff
      `match.utcDate >= now && match.homeScore == null && match.awayScore == null`
- [ ] **Zod schemas**: each of `loginSchema`, `signupSchema`, `tipSchema`,
      `matchImportSchema` accepts a valid payload and rejects each
      documented invalid payload (missing field, wrong type, out of range)
- [ ] **Departments**: `displayDepartment('Maintz')` → `'Mainz'`,
      `displayDepartment('Mannheim')` → `'Mannheim'`

### Playwright (E2E)

Real-browser flows against `next dev` + `shared/db/test.db`:

- [ ] **Auth happy path**: signup → automatic redirect to
      `/login?registered=true` → success banner visible → login →
      land on `/` with the dashboard
- [ ] **Auth disclosure**: from `/login`, attempt (a) unknown email +
      wrong password and (b) known seeded email + wrong password →
      both produce the same error text and the same HTTP status
- [ ] **Logout**: from a logged-in session, click logout → land on
      `/login`; navigating back to `/` redirects to `/login`
- [ ] **Tip submit (scheduled)**: open dashboard → pick a SCHEDULED
      match → enter `2`/`1` → save → row re-renders with the new tip
      visible; reload page → tip persisted
- [ ] **Tip locked (finished)**: open a FINISHED match → no tip-form
      input visible; the prediction column shows the user's recorded tip
- [ ] **Dashboard buckets**: live block lists exactly the 2 IN_PLAY
      seed matches; upcoming list groups the 6 SCHEDULED matches by date
- [ ] **Ranking tabs**: all 4 tabs (Global / Langenfeld / Mannheim /
      Mainz) render rows; the logged-in user's row is visually highlighted;
      the scoring legend shows `4 / 2 / 1 / 0 / +15 / +7`
- [ ] **Match detail**: predictions table sorted by points DESC; status
      badges render correctly for each of the three statuses
- [ ] **Profile**: open `/user/{my-id}` → stat tiles show the seeded
      EXACT/DIFF/WINS/BONUS values; history table contains only `+4`,
      `+2`, `+1`, `0` — no `+150`, no tournament-stage labels

### Suite-level
- [ ] `pnpm test` runs the unit suite in under 5 seconds
- [ ] `pnpm test:e2e` runs the E2E suite in under 90 seconds locally
- [ ] Both suites are deterministic: 10 consecutive runs all green
      without code changes
- [ ] Failure output points to the failing assertion and the seed row
      involved (no opaque snapshots)

## Verification (manual)

1. `cd frontend && pnpm db:reset` → fresh DB
2. `pnpm test` → unit suite green
3. `pnpm test:e2e` → E2E suite green
4. Intentionally break a tested path (e.g. change a label) → the
   corresponding test fails with a clear message; revert → green again

## Notes

Depends on **FE-001…FE-009**. The seed (FE-007) is the data contract;
the security audit (FE-009) is what these tests guard against regressing.

Test data must come from FE-007 — do not create ad-hoc fixtures inside
tests. If a case is hard to reach from the seed, extend FE-007 instead
of adding test-only seeders.
