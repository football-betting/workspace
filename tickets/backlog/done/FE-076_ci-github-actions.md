# FE-076 CI via GitHub Actions (frontend repo)

## Repo
frontend

## Type
chore

## Risk
low

## Priority
medium

## Status
done

## Owner
implementer

## Background
The `football-betting/frontend` repo has no automated check on pushes/PRs. It
already has 25 Vitest unit tests, a working `tsc --noEmit` type-check, and
`@vitest/coverage-v8` installed, but nothing runs them on GitHub. We want a
visible green/red build signal plus a coverage report on Codecov, so
regressions are caught before merge.

## Scope
- **In scope**:
  - `.github/workflows/frontend-ci.yml` — pnpm install, type-check, Vitest +
    coverage, upload to Codecov.
  - `vitest.config.ts` — emit `lcov` coverage for Codecov.
  - `README.md` — CI status badge + Codecov coverage badge.
- **Out of scope (explicit)**:
  - Rust services (`betting-api` / `macht-api`) — separate repos.
  - ESLint: `next lint` was removed in Next 16 and no ESLint flat-config
    exists. Wiring ESLint is a separate ticket. Static analysis here =
    `tsc --noEmit`.

## References
- `package.json` (scripts: `typecheck`, `test`)
- `vitest.config.ts`
- `README.md`

## Acceptance Criteria
- [ ] Push/PR triggers the `frontend-ci` workflow.
- [ ] Workflow runs `pnpm install --frozen-lockfile`, `tsc --noEmit`, and
      `vitest run --coverage` — all green.
- [ ] Coverage `lcov.info` uploaded to Codecov via `CODECOV_TOKEN` secret.
- [ ] `README.md` shows a build-status badge and a Codecov badge.

## Verification (manual)
1. Add `CODECOV_TOKEN` repo secret → push branch → workflow runs green.
2. Open the run → Codecov shows coverage for `lib/**`.
3. README badges render passing + coverage %.
