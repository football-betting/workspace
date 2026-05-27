# [FE-005] Implement match detail page

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
Shows a single match (`/match/[id]`) with the score/status and a table of
**all** users' predictions for that match, sorted by points. Data sources:
local DB for match info, Rust API (`GET /game/{id}`) for the tip list.

## Scope

**In scope:**
- `app/match/[id]/page.tsx` — server component, auth-guarded
- Match header card: home team + flag, score (or `?:?` if scheduled), away team + flag, status badge (LIVE pulsing red / FINISHED / SCHEDULED), kickoff time or match minute
- "User Predictions" table: rank, user (avatar with initials + name), prediction (`2 - 0`), points pill (color-coded)
- Sort: client-side by `score DESC`
- Current user's row highlighted

**Out of scope (explicit):**
- Live polling for score updates (the page is a snapshot per render)
- Match-level chat / comments
- Tournament stage label ("Round of 16", "Group Stage" etc.) — does not exist in the data

## References

- `docs/FRONTEND_FUNKTIONS_SPEC.md` §3 (page table row "/match/[id]")
- `frontend/design/match_detail.html` — visual reference
- `frontend/design/CHANGES.md` §match_detail.html — required edits
- `em2024-frontend/src/pages/match/[id].astro` — original logic

## Acceptance Criteria

### Page render
- [ ] Unauthenticated visitor redirected to `/login`
- [ ] Invalid match ID → redirect to `/` (or render 404)
- [ ] Match header shows both teams with `/svg/{tla}.svg` flags
- [ ] Status badge: `LIVE` (pulsing red dot) / `FINISHED` (neutral) / `SCHEDULED` (subtle)
- [ ] For SCHEDULED matches: show kickoff time instead of score (e.g. `20:00 — Tomorrow`)
- [ ] For IN_PLAY: show match minute (e.g. `64'`) under the score
- [ ] For FINISHED: show "Full Time" sublabel

### Predictions table
- [ ] All users who tipped this match are listed; users without a tip are omitted
- [ ] Sorted by `score DESC` (4 pts first)
- [ ] Each row: rank, avatar circle with initials, full name, prediction `X - Y`, points pill
- [ ] Points pill colors: 4=green, 2=yellow, 1=neutral, 0=red — **NOT** the wrong "Correct Outcome 2 pts" label from the mockup
- [ ] Current user row highlighted (primary tint background + left border)
- [ ] Avatar background color derived from username hash (deterministic, no online indicators / verification badges)

### Mobile
- [ ] Below `md`: table becomes vertical cards (one per prediction)
- [ ] Match header collapses to compact layout
- [ ] Bottom nav visible

## Verification (manual)

1. Log in as `philipp@lahm.de`, click on the live ESP-ENG match from dashboard
2. Match detail loads → header shows 1:1 with LIVE badge pulsing
3. Predictions table: PhilippLahm row highlighted with `1:1` and `+4` (green)
4. Other users with various tips and points (mix of colors visible)
5. Click an avatar/name → navigates to `/user/{id}`
6. Navigate to `/match/1` (Germany 2:0 Spain, FINISHED) → header shows FINISHED, table shows tips sorted with exact matches at top
7. Navigate to `/match/9` (scheduled, future match) → no predictions table or empty placeholder; score area shows kickoff time

## Notes

Depends on FE-001 (bootstrap), FE-002 (login).
