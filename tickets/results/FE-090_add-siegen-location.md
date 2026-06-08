# FE-090 — Result

## What was done
Added Siegen as a selectable office location. Because the frontend drives the
location list, the registration validation, and the leaderboard tabs from a
single `DEPARTMENTS` constant — and the betting-api groups locations dynamically
from the stored (free-text) `department` value — adding the location was a
one-line data change plus the leaderboard deep-link mapping. No Rust or schema
change was needed.

## Files changed
### frontend
- `lib/data/departments.ts` — `DEPARTMENTS` += "Siegen".
- `app/(app)/ranking/page.tsx` — `?tab=siegen` → "Siegen" deep-link mapping.

### betting-api
- None (dynamic department grouping, free-text column).

## Tests / quality gate
- `tsc --noEmit`: clean.
- `vitest run`: 191 passed.
- Verified live: "Siegen" present in the served signup HTML.
- PR #99 (squash-merged), deployed to production.
