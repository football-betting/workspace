# [FE-004] Implement ranking table page

## Repo
frontend

## Type
feature

## Risk
low

## Priority
medium

## Status
todo

## Owner
implementer

## Background
The full ranking page (`/ranking`) lists all users with their stats.
Pure read-only — data comes entirely from `GET /rating` on the Rust API.

## Scope

**In scope:**
- `app/ranking/page.tsx` — server component, auth-guarded
- 4 tabs: Global / Langenfeld / Mannheim / Mainz, each rendering the
  appropriate slice from `data.table.global` or
  `data.table.departments[<name>]`
- Tabs controlled by URL query param (`?tab=langenfeld`) so a refresh keeps state
- Columns: **POS / USERNAME / EXACT / DIFF / WINS / BONUS / TOTAL**
- Highlight current user's row
- On mobile: switch from table to card list below `md` breakpoint
- "Scoring System" info box with the **correct** 4 / 2 / 1 / 0 / +15 / +7 values

**Out of scope (explicit):**
- Pagination (the office pool has 5–50 users, fits on one page)
- Sorting controls (server sorts by total DESC already)
- "Season Rewards / Tournament Prizes" block from the mockup — **remove**
- "European Championship" hardcoded subtitle — make tournament-agnostic

## References

- `docs/FRONTEND_FUNKTIONS_SPEC.md` §3 (page table row "/table")
- `frontend/design/ranking_table.html` — visual reference
- `frontend/design/CHANGES.md` §ranking_table.html — required edits (including scoring fix)
- `em2024-frontend/src/pages/table.astro` — reference for tab logic

## Acceptance Criteria

### Page
- [ ] Unauthenticated visitor redirected to `/login`
- [ ] Authenticated visitor sees title "Leaderboard" + 4 tab buttons + table
- [ ] Default tab is `Global`
- [ ] Click a tab → URL updates to `?tab=langenfeld` etc., table content
      changes without full page reload
- [ ] Direct visit to `/ranking?tab=mainz` → correct tab pre-selected
- [ ] Tournament-specific text removed; subtitle reads "Office tournament
      standings" (or whatever passes as neutral)

### Table
- [ ] All 7 columns render with correct headers
- [ ] Numbers use `font-mono` (JetBrains Mono) for tabular alignment
- [ ] Current user's row has visible highlight (primary background tint,
      left border accent)
- [ ] Empty department (no users) → shows "No users in this department" placeholder
- [ ] Username links to `/user/{user_id}`

### Scoring System info box
- [ ] Lists: Exact Score **4 Pts**, Goal Difference **2 Pts**, Correct
      Outcome **1 Pt**
- [ ] Lists: Tournament Winner **+15 Pts (bonus)**, Secret Winner **+7 Pts (bonus)**
- [ ] No "Season Rewards / Tournament Prizes" block anywhere

### Mobile
- [ ] Below `md`: table becomes card list (one card per user with stacked stats)
- [ ] Mobile column abbreviations: RE / T / S / EP / P (match the old UI pattern)
- [ ] Bottom nav visible, "Ranking" item active

## Verification (manual)

1. Log in, navigate to `/ranking`
2. Default tab Global → 7 users listed with correct totals (PhilippLahm
   first at 23P from current seed data)
3. Click "Langenfeld" → 3 users; click "Mannheim" → 2 users; click
   "Mainz" → 2 users
4. Logged-in user row visually distinguished in every tab where they appear
5. Click a username → navigates to `/user/{id}` (404 OK for now if FE-006
   not done)
6. Resize to 375px → table → card layout, all data still visible

## Notes

Depends on FE-001 (bootstrap), FE-002 (login).
