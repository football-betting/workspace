# [FE-006] Implement user profile page

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
User profile (`/user/[id]`) shows one user's full stats and prediction
history. Most data comes from `GET /user/{id}` on the Rust API; the
winner/secretWinner fields come from the local DB.

## Scope

**In scope:**
- `app/user/[id]/page.tsx` — server component, auth-guarded
- Header: username + global ranking number + total points
- 4 stat tiles: EXACT / DIFF / WINS / BONUS
- Two flag cards: Tournament Winner (trophy icon) + Secret Winner (hidden-eye icon)
- Prediction history table: match, prediction, result, points (color-coded)
- Match name links to `/match/{id}`

**Out of scope (explicit):**
- Tournament-stage sublabels (Quarter-finals, Round of 16 etc.) — do not exist
- Mega-point values like `+150` — points are always **+4 / +2 / +1 / 0**
- Avatar upload / online status / "PRO" badges / verification icons
- Achievement system, trophies, league badges

## References

- `docs/FRONTEND_FUNKTIONS_SPEC.md` §3 (page table row "/user/[id]")
- `frontend/design/profile.html` — visual reference
- `frontend/design/CHANGES.md` §profile.html — required edits
- `em2024-frontend/src/pages/user/[id].astro` — original logic
- Rust endpoint: `GET /user/{user_id}` returns `{data: UserRating}` with `tips` sorted by date DESC

## Acceptance Criteria

### Page render
- [ ] Unauthenticated visitor redirected to `/login`
- [ ] Invalid user ID → 404 (or redirect to `/`)
- [ ] Header section: large username, "#142" rank number (use real value),
      total points (use real value)

### Stat tiles
- [ ] 4 tiles: EXACT (sum_win_exact), DIFF (sum_score_diff), WINS (sum_team), BONUS (extra_point)
- [ ] Numbers in `font-mono` (JetBrains Mono)

### Winner cards
- [ ] Two cards side-by-side: TOURNAMENT WINNER (label) + flag of `user.winner`
- [ ] SECRET WINNER (label) + flag of `user.secretWinner`
- [ ] Trophy icon decoration (Material Symbol `emoji_events`) on Tournament Winner
- [ ] Hidden-eye icon (Material Symbol `visibility_off`) on Secret Winner
- [ ] Flags via `<img src="/svg/{tla}.svg">` — no inline SVG

### Prediction history
- [ ] Header has tournament name from config (NOT hardcoded "SEASON 2024")
- [ ] Columns: Match (with date sublabel), Prediction, Result, Points
- [ ] **No** "Quarter-final / Semi-final / Round of 16" labels — use the
      match date (e.g. `Sa, 15. Juni`)
- [ ] Points column: **+4 / +2 / +1 / 0** values only — never +150 / +50
- [ ] Points color-coded: 4=green, 2=yellow, 1=neutral, 0=red
- [ ] If user has no predictions yet → "No predictions yet" placeholder
- [ ] Match column links to `/match/{id}`

### Mobile
- [ ] Below `md`: stat tiles stack 2x2, winner cards stack vertically
- [ ] History table → card list
- [ ] Bottom nav visible, "Profile" item active when viewing own profile

## Verification (manual)

1. Log in as `philipp@lahm.de` (id 3, winner=ESP, +15 bonus)
2. Click "Profile" in nav → land on `/user/3`
3. Header shows PhilippLahm, rank #1, 23 points
4. Stat tiles: EXACT=1, DIFF=1, WINS=2, BONUS=15
5. Winner card shows Spain flag with trophy icon
6. Secret Winner card shows England flag with hidden-eye icon
7. History table lists all 5 of PhilippLahm's tips, sorted by date DESC
   (live ESP-ENG at top with +4 green), correct colors throughout
8. Click on the ESP-ENG row → navigates to `/match/5`
9. Visit `/user/7` (Steve McManaman, hardly any tips) → page renders
   with sparse history table

## Notes

Depends on FE-001 (bootstrap), FE-002 (login).
This is the last page ticket. After FE-006, the frontend has feature parity
with the legacy Astro version.
