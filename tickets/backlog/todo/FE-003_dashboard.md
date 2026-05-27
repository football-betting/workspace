# [FE-003] Implement dashboard page

## Repo
frontend

## Type
feature

## Risk
medium

## Priority
high

## Status
todo

## Owner
implementer

## Background
The dashboard is the landing page for logged-in users. It combines three
data sources: live match scoring (from Rust API), upcoming fixtures with
tip input (direct DB), and a mini ranking sidebar (from Rust API).

This is the most complex page — touches DB writes, Rust API reads, and
client-side interactivity for tip submission.

## Scope

**In scope:**
- `app/page.tsx` (route `/`) — server component, auth-guarded
- Live-match section: pulls matches with `status='IN_PLAY'` from local DB,
  enriches with user's tip + current points via `fetchApi('user/{id}')`
- Upcoming-fixtures section: matches where `utcDate > now`, grouped by date,
  each with a `<TipForm>` client component
- Mini ranking sidebar (`<ShortTable>` component) with 4 tabs:
  Global / Langenfeld / Mannheim / Mainz; current user highlighted
- `<TipForm>` client component: two number inputs (0–20), Save button,
  optimistic update on success, inline error on failure
- `app/api/tip/[matchId]/route.ts` — POST handler (validation per spec §5.3)
- Bottom navigation on mobile (Dashboard / Ranking / Profile)

**Out of scope (explicit):**
- Full ranking page (separate ticket FE-004)
- Match detail page (FE-005)
- User profile (FE-006)
- The "Quick Stats" widget from the mockup — **remove it** (see CHANGES.md)

## References

- `docs/FRONTEND_FUNKTIONS_SPEC.md` §3 (page table row "/"), §5.3 (tip handler), §8.3 (live block lifecycle)
- `frontend/design/dashboard.html` — visual reference
- `frontend/design/CHANGES.md` §dashboard.html — required edits
- `em2024-frontend/src/pages/index.astro` — original logic to mirror
- `em2024-frontend/src/lib/match.ts` — `getFutureMatch`, `getLiveMatch`
- `em2024-frontend/src/lib/tip.ts` — `saveTip`, `getTipByUserAndMatchIds`
- `em2024-frontend/src/lib/api.ts` — `getRating` ranking slicing logic
- `em2024-frontend/src/components/ShortTable.astro` — reference for sidebar

## Acceptance Criteria

### Page render
- [ ] Unauthenticated visitor is redirected to `/login`
- [ ] Authenticated visitor sees: mini ranking (left or right column),
      live matches (if any), upcoming fixtures grouped by date
- [ ] Live match block hidden entirely if no matches in `status='IN_PLAY'`
- [ ] "No upcoming fixtures" placeholder shown if all future matches
      filtered out
- [ ] Match cards display flags via `<img src="/svg/{tla}.svg">`, never inline SVG

### Live match block
- [ ] For each live match: shows teams (with flags), current score,
      match minute (e.g. `64'`), the user's tip, and points earned so far
- [ ] Points displayed with correct color: 4=green (success), 2=yellow
      (warning), 1=neutral, 0=red (error)
- [ ] If user has no tip for a live match, the row is excluded from the
      block (matches spec §8.3)

### Upcoming fixtures
- [ ] Matches sorted ASC by `utcDate`, grouped by date heading
      (`Samstag, 15. Juni 2024` German locale)
- [ ] Each match: two number inputs, both required, min=0, max=20
- [ ] If user has existing tip, inputs pre-filled and Save button shows
      "Edit" state
- [ ] On Save → `POST /api/tip/{matchId}` → optimistic update on 200
- [ ] On error → inline message under the row, inputs remain editable
- [ ] Match disabled (`opacity-60`, inputs disabled, Save hidden) if
      `matchDate < now` OR `homeScore !== null` OR `awayScore !== null`

### Tip save handler (`/api/tip/[matchId]`)
- [ ] 401 + `"Not logged in"` if no session
- [ ] 400 + `"Match not found"` if matchId invalid or not in DB
- [ ] 400 + `"Match already started or finished"` if match no longer tippable
- [ ] 400 + `"Tip out of range (0–20)"` if tip1 or tip2 outside range
- [ ] On success: upsert tip with `date = new Date()`, return
      `{ success: true, tip: {...} }` (200)

### Ranking sidebar
- [ ] 4 tabs render the same list of users, sliced per tab
- [ ] Slicing logic matches spec §14.3:
  - User found in `global[3..]` with index > 0: top 3 + 3 neighbors
  - Otherwise: top 6 only
- [ ] Current user row visually distinguished (primary background tint + left border)
- [ ] "View Full Ranking" link → `/ranking`
- [ ] Each user row links to `/user/{user_id}`

### Mobile
- [ ] Single-column layout below `md` breakpoint
- [ ] Bottom nav fixed at the bottom (Dashboard active)
- [ ] Top nav hidden below `md`
- [ ] Number inputs large enough to tap (`min-h-12`)

## Verification (manual)

1. Log in as `philipp@lahm.de / test123` (has live tip 1:1 for ESP-ENG)
2. Dashboard renders → Live block shows ESP-ENG with `+4` (green)
3. Upcoming fixtures → tip on NED-POL with `2:0`, click Save → row updates
   without page reload
4. Tab through ranking sidebar (Global → Langenfeld → Mannheim → Mainz) →
   different lists, user highlighted in Langenfeld
5. Open `/match/5` via clicking a live match row (next ticket)
6. Resize to 375px → bottom nav visible, layout single-column, taps work
7. Network tab: no failed requests, no console errors

## Notes

Depends on FE-001 (bootstrap) and FE-002 (login working so test users
can sign in).
