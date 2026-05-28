# FE-004 — Ranking page

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#7](https://github.com/football-betting/frontend/pull/7) (squash → `98718e1`)

## What was done
New `/ranking` route with 4 tabs (Global + Langenfeld + Mannheim + Maintz), backed by the same Rust `/rating` endpoint as the dashboard sidebar. Desktop 7-column table, mobile card list, current user highlighted with "YOU" pill. Scoring infobox shows the correct 4/2/1/+15/+7 values (CHANGES.md §ranking_table.html fixes applied — no 5/3/2 mockup bug, no Season Rewards block).

## Files (4 new / 0 modified)
- `app/(app)/ranking/page.tsx` (~127 LOC) — RSC, auth-guarded via `(app)` layout, Rust-offline fallback
- `components/ranking/RankingTable.tsx` (~196 LOC) — dual desktop/mobile layouts
- `components/ranking/RankingTabs.tsx` (~62 LOC) — client, URL-aware via `router.replace`
- `components/ranking/ScoringInfobox.tsx` (~33 LOC) — 5 rows with the correct values

## Reviewer verdict — APPROVE WITH NOTES
Non-blocking: URL casing — `router.replace` writes `?tab=Maintz` while the ticket example uses `?tab=mainz`. Both directions parse correctly via case-insensitive resolver, so no functional impact. Can be canonicalized to lowercase in a later cleanup.
