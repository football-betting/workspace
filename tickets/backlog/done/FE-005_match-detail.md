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
- [ ] For SCHEDULED matches: show kickoff time in German locale
      (e.g. `Sa, 15. Juni · 18:00`) instead of the score
- [ ] For IN_PLAY: show match minute under the score (e.g. `64'`) — if the
      Rust API does not yet expose minute, render `LIVE` only and document
      the gap; do not fabricate a minute
- [ ] For FINISHED: show "Full Time" sublabel

### Predictions table
- [ ] All users who tipped this match are listed; users without a tip are omitted
- [ ] Sorted by `score DESC` (4 pts first)
- [ ] Each row: rank, avatar circle with initials, full name, prediction `X - Y`, points pill
- [ ] Points pill colors: 4=green, 2=yellow, 1=neutral, 0=red
- [ ] **Label consistency** (the HTML mockup has these paired wrong — fix
      while porting): `4 pts = Exact Score`, `2 pts = Goal Difference`,
      `1 pt = Correct Outcome`, `0 pts = Wrong`. If any label appears in
      the page (e.g. as a tooltip or legend), it must use these exact
      pairings.
- [ ] Current user row highlighted (primary tint background + left border)
- [ ] Avatar background color derived from username hash (deterministic, no online indicators / verification badges)

### Mobile
- [ ] Below `md`: table becomes vertical cards (one per prediction)
- [ ] Match header collapses to compact layout
- [ ] Bottom nav visible

## Verification (manual)

> Pre-requisite: FE-007 seed loaded. Login as `me@dev.local` / `test123`
> (TestUser, Langenfeld). Match IDs below refer to the FE-007 seed.

1. From the dashboard, click on a live (IN_PLAY) match → match detail loads
2. Header shows the running score with a LIVE badge pulsing red
3. Predictions table: TestUser row highlighted; mix of point colors visible
   across all listed users (green/yellow/neutral/red)
4. Click another user's avatar/name → navigates to `/user/{id}`
5. Open a FINISHED match → header shows "Full Time" sublabel; table is
   sorted with 4-pt rows at the top
6. Open a SCHEDULED match → header shows kickoff time in German locale
   instead of a score; predictions area shows the empty-state placeholder
   (no one has tipped yet OR predictions are hidden until kickoff,
   whichever the spec prescribes — match it)

## Notes

Depends on FE-001 (bootstrap), FE-002 (login).
