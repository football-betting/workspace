# FE-010 — Vitest + Playwright test suite

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#13](https://github.com/football-betting/frontend/pull/13) (squash → `e4cefcf`)

## What was done
- **Vitest (43 tests, ~150 ms)** across 6 files: scoring, date helpers, Zod schemas (login/signup/match-import), department mapping, score-color, tip eligibility.
- **Playwright (12 tests, ~22 s)** across 7 specs + 1 globalSetup against `shared/db/test.db`: auth happy path, disclosure parity, tip submit, tip locked, dashboard buckets, ranking tabs + legend (Rust-offline tolerant), match-detail status badges, profile history negatives.
- Five `package.json` scripts: `test`, `test:unit`, `test:watch`, `test:e2e`, `test:e2e:headed`.
- `vitest.config.ts`, `playwright.config.ts`, `.env.test.example` (and `.env.test` gitignored per workspace rule).

## Real bug fixed (in-scope per spec §14.1)
- `lib/format.ts` `formatDate` was drifting from the spec-mandated German format. Restored to `{ weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }` so it returns `"Samstag, 31. Dezember 2022"` verbatim. Affects UpcomingList, MatchHeader, PredictionHistory.

## Reviewer verdict — APPROVE WITH NOTES
Non-blocking observations:
1. AC mentions `tipSchema` — schema does not exist in the codebase (the tip route validates inline). Either an FE-002/003 follow-up to extract a Zod schema, or amend the spec.
2. `profile.spec.ts` asserts the four stat-tile labels are present but not their numeric values (values depend on the Rust API being up).

## Files (~700 LOC test code / 2 lib changes / 4 config files)
- 6 unit tests + 7 e2e specs + 1 globalSetup
- `vitest.config.ts`, `playwright.config.ts`, `.env.test.example`, `.gitignore` (+1 line)
- `lib/format.ts` (+2/-1 LOC bug fix), `package.json` (+5 scripts + 3 devDeps), `pnpm-lock.yaml`

## Quality gates
- `pnpm exec tsc --noEmit` clean
- `pnpm build` clean
- `pnpm test` → 43/43 in ~150 ms
- `pnpm test:e2e` → 12/12 in ~26.5 s
- Determinism: two consecutive runs identical
