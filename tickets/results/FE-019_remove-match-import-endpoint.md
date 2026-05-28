# FE-019 — Remove /api/match/import (dead code)

**Status:** done · **Merged:** 2026-05-28 · **PR:** [#18](https://github.com/football-betting/frontend/pull/18) (squash → `b84172c`)

## What was done
- Deleted `app/api/match/import/route.ts` (~124 LOC) and `lib/validation/match-import.ts` (~30 LOC)
- Removed the `/api/match/import` pass-through from `middleware.ts` (~3 LOC)
- Dropped `MATCH_IMPORT_API_KEY` from `.env.example`
- Removed the `matchImportSchema` test block from `tests/unit/validation.test.ts` (6 cases / ~55 LOC)
- Spec §3, §4.3, §5.4, §19.1-mapping all updated
- `XR-001_macht-api-x-api-key-cutover` moved to `done/` as superseded; result doc explains why
- `FE-008_match-import-api.md` result doc carries a "Superseded by FE-019" footer
- Demo seed (`scripts/demo_data.ts`, FE-007) untouched and verified — still produces 8 / 12 / 48 rows

## Smoke
- `POST /api/match/import` → 403 Forbidden (CSRF reject — middleware special-case is gone, so the request looks like any other Origin-less POST; no information about which routes ever existed)
- `pnpm db:reset` runs in <1.5 s and inserts 8 users / 12 matches / 48 tips

## Quality gates
- 47 / 47 Vitest (was 53; -6 matchImportSchema cases)
- 13 / 13 Playwright unchanged
- `pnpm exec tsc --noEmit` clean
- `pnpm build` clean
