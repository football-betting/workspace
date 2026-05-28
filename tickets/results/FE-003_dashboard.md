# FE-003 — Dashboard

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#6](https://github.com/football-betting/frontend/pull/6) (squash → `6dad509`)

## What was done
Replaced the FE-001 placeholder at `app/(app)/page.tsx` with the full dashboard: live block (IN_PLAY matches with user's tip + color-coded points pill), upcoming fixtures grouped by date (German locale, ASC), TipForm per row, ranking sidebar with 4 tabs + ShortTable slicing per spec §14.3, mobile bottom nav.

## Files (~1100 LOC / 15 new + 2 modified)

**New libs:** `lib/match.ts` · `lib/tip.ts` · `lib/rating.ts` · `lib/scoring.ts` · `lib/score.ts` · `lib/format.ts`

**New components:** `components/dashboard/` × 9 (Flag, TopAppBar, BottomNav, LiveBlock, UpcomingList, MatchRow, TipForm [client], RankingSidebar, TabBar [client])

**New API:** `app/api/tip/[matchId]/route.ts` — POST upsert, 401 only for missing session, 400 for match-not-found / match-already-started-or-finished / out-of-range (fixes spec §5.3 legacy 401-everywhere bug)

**Modified:** `app/(app)/page.tsx` (dashboard), `app/globals.css` (+4 score color tokens in `@theme`)

## Reviewer verdict — APPROVE
All ACs satisfied. Auth boundary verified (session check first). Scoring formula correct for all 4 cases (exact/diff/winner-or-draw/wrong). JSON team narrowing via type guard (no `any`). Rust API offline handled gracefully. No N+1 (tips in one `inArray` query). Material Symbols only, no inline SVG.

## Decisions
1. **Local points compute** in LiveBlock (via `computeScore(tip, match)`) instead of a second Rust round-trip — dashboard works whether Rust is up or down.
2. **Single TabBar client component** owns state; server pre-renders all 4 panels with `hidden` attribute — no per-tab fetch.
3. **TipForm uses `router.refresh()`** after successful POST — server re-fetches tips and the row renders in EDIT state without a hard reload.
4. **TLA mapping preserved** in `Flag.tsx` (DEU→GER, NLD→NED, HRV→CRO, etc.) so the seed's ISO-3 codes resolve to the public/svg/ filenames.
