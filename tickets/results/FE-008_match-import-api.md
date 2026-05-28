# FE-008 — Match-Import API (frontend half)

**Status:** done (frontend half) · **Merged:** 2026-05-28 · **PR:** [#11](https://github.com/football-betting/frontend/pull/11) (squash → `39b88c5`)

## Scope split
This was a multi-repo ticket (frontend + macht-api). Only the frontend half is in this PR. The Rust importer cutover is tracked as `XR-001_macht-api-x-api-key-cutover` in the workspace todo.

## What was done (frontend half)
- POST `/api/match/import` with constant-time `x-api-key` check via `node:crypto.timingSafeEqual`, identical 401 shape for both wrong-key branches
- Zod-validated payload (id positive int, home/awayTeam, status enum, utcDate, optional score/homeScore/awayScore)
- Drizzle `onConflictDoUpdate` by `match.id` — true upsert
- 405 with `Allow: POST` for GET/HEAD/PUT/DELETE/PATCH
- Middleware: exact-match pass-through for `/api/match/import` only; every other non-GET still goes through `verifyRequestOrigin` (smoke-verified)
- No `MATCH_IMPORT_API_KEY` env → 500 `server misconfigured` (env-var name not leaked in response body)

## Files (~158 LOC / 2 new + 1 modified)
- `app/api/match/import/route.ts` (~124 LOC)
- `lib/validation/match-import.ts` (~30 LOC)
- `middleware.ts` (+4 LOC)

## Reviewer verdict — APPROVE
Auth boundary verified (constant-time + identical body/headers), CSRF preserved everywhere else, schema exhaustive, no scope creep, no `any`, tsc + build clean.

---

## Superseded by FE-019 (2026-05-28)

The `/api/match/import` endpoint introduced here was removed in
[FE-019](FE-019_remove-match-import-endpoint.md). Owner decision:
the importer was dead code in our actual architecture — `macht-api`
writes to SQLite directly via `rusqlite`, the HTTP hop was only ever
intended for a multi-host setup that never materialised. Removing
reduces attack surface and eliminates the per-framework-upgrade
maintenance tax.

Companion `XR-001_macht-api-x-api-key-cutover` is closed without
implementation: nothing to cut over to.
