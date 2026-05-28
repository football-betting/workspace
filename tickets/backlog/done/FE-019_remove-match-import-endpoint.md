# [FE-019] Remove /api/match/import — unused in our architecture

## Repo
frontend

## Type
chore

## Risk
low

> Removing an endpoint that is genuinely dead in our deployment.
> macht-api writes to SQLite directly via rusqlite; nothing calls the
> HTTP route. Demo data lands via `pnpm db:seed` (FE-007), not via
> this endpoint.

## Priority
high

## Status
todo

## Background
FE-008 built a `POST /api/match/import` handler with x-api-key auth as
a frontend-side hook for the Rust importer. The spec §5.4 already
flagged that endpoint as **"Aktuell unbenutzt"** — `macht-api` writes
straight into SQLite via `rusqlite`, no HTTP hop required.

Owner decision (2026-05-28): remove it. Dead code is a maintenance
tax — FE-009 and FE-014 both had to extend it for security headers,
and any future Next.js bump (FE-012) needs to keep it working too.
If a multi-host setup is ever needed, the endpoint is a 30-minute
rebuild from this ticket's history.

Demo data continues to come from `scripts/demo_data.ts` via
`pnpm db:seed` (FE-007). That script writes via `better-sqlite3`
directly and has nothing to do with the HTTP route.

## Scope

**Remove:**
- `app/api/match/import/route.ts` (route handler)
- `lib/validation/match-import.ts` (Zod schema — only consumer is the
  route)
- The `/api/match/import` pass-through block in `middleware.ts`
- `MATCH_IMPORT_API_KEY` line from `.env.example`
- `matchImportSchema` cases in `tests/unit/validation.test.ts`

**Update:**
- `docs/FRONTEND_FUNKTIONS_SPEC.md` §3 page table — drop the
  `/api/match/import` row; §4.3 — drop the `Origin: RUST_APPLICATION`
  Ausnahme bullet (already moot); §5.4 — replace with a one-line
  note "Removed in FE-019 (2026-05-28)"; §19.1 — drop the API-key
  recommendation for that route
- `tickets/backlog/todo/XR-001_macht-api-x-api-key-cutover.md` →
  close out as **superseded**. Move to a new
  `tickets/backlog/done/` entry with a one-line note that the
  endpoint it was supposed to align with has been removed
- `tickets/results/FE-008_match-import-api.md` — add a "Superseded by
  FE-019" footer

**Keep:**
- `scripts/demo_data.ts` (FE-007) — completely independent
- `scripts/migrate.ts` — same
- `scripts/reset.ts` — same

## Acceptance Criteria

- [ ] `app/api/match/import/`, `lib/validation/match-import.ts` gone
- [ ] `middleware.ts` no longer has the special-case skip
- [ ] `curl -si -X POST http://localhost:3000/api/match/import` → 404
      (Next.js default for unknown routes), not 401
- [ ] `.env.example` has no `MATCH_IMPORT_API_KEY` line
- [ ] `tests/unit/validation.test.ts` — no `matchImportSchema` block
- [ ] `pnpm exec tsc --noEmit` clean
- [ ] `pnpm build` clean
- [ ] All remaining tests green: Vitest ≤53 (some removed) +
      13 Playwright
- [ ] Spec §5.4 reads "Removed in FE-019 (2026-05-28)"
- [ ] XR-001 moved to `done/` with a one-line "superseded" note
- [ ] FE-008 result doc carries a one-line "Superseded by FE-019" footer
- [ ] Demo seed still works: `pnpm db:reset` populates 8 users / 12
      matches / 48 tips
