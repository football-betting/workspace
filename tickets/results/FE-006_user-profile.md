# FE-006 — User profile page

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#10](https://github.com/football-betting/frontend/pull/10) (squash → `66f9523`)

## What was done
New `/user/[id]` route with header + 4 stat tiles + winner cards + prediction history. Defensive `clampPerMatchPoints` ensures the history shows only `+4/+2/+1/0` — bonuses `+15/+7` appear only in the BONUS tile aggregate. Tournament name in `lib/data/tournament.ts`; no hardcoded "SEASON 2024". Active-profile detection highlights the BottomNav Profile pill when viewing own profile.

## Files (5 new + 1 modified, ~414 LOC)
- `app/(app)/user/[id]/page.tsx` (94 LOC)
- `components/profile/ProfileHeader.tsx` (47), `StatTiles.tsx` (38), `WinnerCards.tsx` (57), `PredictionHistory.tsx` (173)
- `lib/data/tournament.ts` (1) — `TOURNAMENT_NAME`
- `lib/user.ts` (+6) — pure additive `getUserById(id)`

## Reviewer verdict — APPROVE
Auth boundary verified, AC contract line-by-line satisfied, defensive cap cannot be bypassed, Rust-offline degrades gracefully.
