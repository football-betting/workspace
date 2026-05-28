# [XR-001] Cut macht-api over to x-api-key (companion to FE-008)

## Repo
macht-api

## Type
chore

## Risk
medium

> Production importer. A regression breaks the live match data pipeline.

## Priority
medium

## Status
todo

## Owner
implementer (Rust track)

## Background
[FE-008](../done/FE-008_match-import-api.md) replaced the frontend's
legacy `Origin: RUST_APPLICATION` magic-string bypass with a real
`x-api-key` header check on `POST /api/match/import`. The new
frontend is live; the legacy bypass no longer exists.

`macht-api` currently still overrides the `Origin` header to
`RUST_APPLICATION` per `macht-api/src/api/match_client.rs`. Until
this ticket lands, the importer will be rejected by the frontend's
`verifyRequestOrigin` middleware (the import route is now
auth-by-header, not auth-by-Origin-bypass).

## Scope

**In scope:**
- `macht-api/src/api/match_client.rs` — read
  `MATCH_IMPORT_API_KEY` from env, send as `x-api-key` header on every
  importer call, stop setting `Origin: RUST_APPLICATION`
- `macht-api/.env.example` — document `MATCH_IMPORT_API_KEY`
- Whatever Rust deserialization + struct field naming changes are
  needed to match the frontend's Zod payload shape (it's already in
  lockstep with the schema, so usually a no-op)

**Out of scope:**
- Schema changes (none required)
- Re-architecting the importer's scheduling
- Per-IP allowlist (the API key is the trust boundary; rotate the
  env var if leaked)

## References
- `frontend/app/api/match/import/route.ts` — the handler this importer talks to
- `frontend/lib/validation/match-import.ts` — Zod schema (payload contract)
- `frontend/middleware.ts` — pass-through gate
- `docs/FRONTEND_FUNKTIONS_SPEC.md` §4.3, §5.4, §19.1
- Companion ticket: `tickets/backlog/done/FE-008_match-import-api.md`

## Acceptance Criteria

- [ ] Rust importer reads `MATCH_IMPORT_API_KEY` from env; missing env
      fails loudly at startup (not silently)
- [ ] Every importer POST carries the `x-api-key` header with the env value
- [ ] No code path still sets `Origin: RUST_APPLICATION`
- [ ] `macht-api/.env.example` documents the variable
- [ ] `cargo clippy -- -D warnings` clean
- [ ] `cargo test` green
- [ ] One real cron tick succeeds end-to-end against the new frontend
      handler; new match rows appear in the shared DB

## Notes

Coordinated rollout (already handled): the frontend ships first (the new
handler is independently deployable; the legacy `Origin` bypass no
longer exists). When this XR ticket lands, the importer flips to the
header on the next deploy.
