# FE-005 — Match detail page

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#8](https://github.com/football-betting/frontend/pull/8) (squash → `d6574cd`)

## What was done
New `/match/[id]` route. Status badges (LIVE pulsing / FULL TIME / SCHEDULED), German-locale kickoff sublabel for SCHEDULED, predictions table sorted by `score DESC`, current-user row highlighted with `YOU` pill, deterministic HSL avatar from username hash. Live-minute prop is wired through `<MatchHeader>` but never fabricated — Rust API doesn't yet expose a minute field.

## Files (3 new / 0 modified, ~569 LOC)
- `app/(app)/match/[id]/page.tsx` (~172 LOC) — RSC, regex-validated id, `notFound()` for invalid/missing, Rust-offline fallback
- `components/match/MatchHeader.tsx` (~162 LOC) — score card + status badge variants + German-locale kickoff
- `components/match/PredictionsTable.tsx` (~235 LOC) — desktop table + mobile cards, color pills, deterministic HSL avatar, per-row link to `/user/{id}`

## Reviewer verdict — APPROVE WITH NOTES
Non-blocking cosmetics: em-dash vs hyphen in `formatPrediction`, FULL TIME duplicated in badge + sublabel, two hard-coded hex colors in `pillClass` instead of design tokens.

## Out-of-scope finding (will get its own hotfix)
Seed password `test123` (7 chars) collides with FE-002 `loginSchema.min(8)` — the 8 seeded users can't log in until the seed password is updated.
