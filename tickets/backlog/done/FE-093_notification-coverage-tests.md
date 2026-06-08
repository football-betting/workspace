# FE-093 Test coverage for the notification path + recent logic

## Repo
frontend

## Type
test

## Risk
low

## Background
The tip-reminder pipeline had only been validated by hand against the production
DB — not repeatable, not in CI, and missing the failure/channel paths. The cron
route orchestration had no automated test, and recent additions (localized team
names, branded reminder email, small helpers) were untested.

## Scope
- in: new vitest unit tests only. No production code change.
- out: DB-wrapper modules that need a live DB (push-store, reminder-store, tip,
  user, session) — left for a separate integration-DB effort.

## What changed (new tests)
- `cron-notifications.test.ts` (12) — mocks the data + delivery layers, runs the
  real eligibility logic: auth (401/405), untipped filter, dedup, email/push
  channel selection, mark-on-success retry, gone-endpoint pruning, two matches
  same kickoff, and multiple lead windows firing together near kickoff.
- `teams.test.ts` (9) — `teamName`/`localizedTeams` (de/en, sort, fallback),
  `isTeamCode`, `TEAM_CODES`.
- `tip-reminder-email.test.ts` (2) — branded HTML contents + HTML escaping.
- `error-message.test.ts` (3), `app-origin.test.ts` (3),
  `validation-schemas.test.ts` (5).

## Acceptance / verification
- `tsc --noEmit` clean; `vitest run` 225 passed (was 191, +34).
- Test-only; no deploy. PR #102.
