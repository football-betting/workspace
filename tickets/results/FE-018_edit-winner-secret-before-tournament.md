# FE-018 — Edit winner + secretWinner before tournament starts

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#19](https://github.com/football-betting/frontend/pull/19) (squash → `a7eeb1b`)

## What was done
Promotes spec §19.5 "Pre-Turnier-Sperre" from Nice-to-have to feature. Own profile shows Edit buttons on each Winner card; clicking opens a form with two team selects. Locked the moment any match reaches kickoff. Server endpoint enforces the lock regardless of UI state.

## Files (~427 LOC / 7 new + 3 modified)
- `lib/tournament.ts` (~19 LOC) — `isTournamentLocked()` + pure `isLockedFromTimestamp()` helper
- `lib/validation/winners.ts` (~18 LOC) — Zod schema
- `app/api/user/winners/route.ts` (~99 LOC) — POST: session → rate-limit → lock → Zod → DB. userId from session only.
- `components/profile/WinnerEditForm.tsx` (~142 LOC) — Client form
- `tests/unit/tournament.test.ts` (~25 LOC) — 4 cases
- `tests/unit/winners-validation.test.ts` (~47 LOC) — 5 cases
- `tests/e2e/winner-edit.spec.ts` (~77 LOC) — 5 locked-path specs
- `lib/user.ts` (+ `updateUserWinners`)
- `components/profile/WinnerCards.tsx` (now Client, `editable` prop)
- `app/(app)/user/[id]/page.tsx` (computes `locked` server-side)

## Reviewer verdict — APPROVE WITH NOTES
- Auth/IDOR deep check passed (userId from `getCurrentSession()` only; no body/URL path)
- Lock-check timestamps unit-consistent (raw SQLite seconds vs JS ms — multiplied at the boundary)
- Server/Client boundary clean (`page.tsx` stays server; `WinnerCards`/`WinnerEditForm` are client)
- Quality gates clean: 56 vitest + 18 e2e tests, tsc + build clean

Non-blocking follow-up candidates:
- Vestigial `userId` prop on `<WinnerCards>` could be removed
- Add `TOURNAMENT_LOCK_OVERRIDE` env or future-dated seed match to e2e-cover the unlocked happy path
- Document the rate-limit-before-lock ordering in the route header
