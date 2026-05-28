# [FE-008] Match-import API with API-key auth (replaces magic-string Origin)

## Repo
multi

> Touches `frontend/` and `macht-api/`. Implementation order in Notes.

## Type
feature

## Risk
medium

> Production-facing endpoint called by the Rust importer on every cron tick.
> A regression here freezes match data updates.

## Priority
medium

## Status
todo

## Owner
implementer

## Background
The legacy Astro frontend exposed `POST /api/match/import` to receive
match upserts from `macht-api`. Authentication relied on a magic string
in the `Origin` header (`Origin: RUST_APPLICATION`) bypassing the CSRF
middleware. This is documented as a security finding in
`docs/FRONTEND_FUNKTIONS_SPEC.md` §4.3 and §19.1.

The Next.js rebuild replaces the magic string with a real API key sent
in `x-api-key`. The handler validates the key, validates the payload
with Zod, and upserts the match row. The Rust importer is updated to
send the header instead of overriding `Origin`.

## Scope

**In scope (frontend):**
- `app/api/match/import/route.ts` — POST handler
- Reads API key from `process.env.MATCH_IMPORT_API_KEY` (server-only,
  not `NEXT_PUBLIC_…`)
- Compares `x-api-key` header in constant time (`crypto.timingSafeEqual`)
- Zod schema for the match payload (id, homeTeam, awayTeam, status,
  utcDate, score?, homeScore?, awayScore?)
- Upsert into `match` table via Drizzle (insert or update by `id`)
- Middleware exception: skip CSRF/Origin check for this route (the API
  key replaces the Origin gate)
- `.env.example` documents `MATCH_IMPORT_API_KEY`

**In scope (macht-api):**
- Read API key from env (`MATCH_IMPORT_API_KEY`)
- Send it as `x-api-key` header instead of overriding `Origin`
- Update README / env docs if relevant

**Out of scope (explicit):**
- Reworking the Rust importer's scheduling or external API client
- Migrating any other endpoint to API-key auth
- Per-IP allowlist (the API key is the trust boundary; if leaked,
  rotate the env var)

## References

- `docs/FRONTEND_FUNKTIONS_SPEC.md` §4.3 (current Origin-bypass),
  §5.4 (handler), §19.1 (security recommendations)
- `em2024-frontend/src/pages/api/match/import.ts` — original handler
- `em2024-frontend/src/middleware.ts` — original `Origin: RUST_APPLICATION`
  exception
- `macht-api/src/api/match_client.rs` — where the importer currently
  sets the `Origin` header

## Acceptance Criteria

### Frontend handler
- [ ] `POST /api/match/import` with a valid `x-api-key` and a valid
      payload → 200 `{ok: true, id: <matchId>}`
- [ ] Missing or wrong `x-api-key` → 401 `{error: "invalid api key"}`
      (constant-time compare; both branches return identical-shape JSON
      and identical latency within reason)
- [ ] Malformed payload (Zod fails) → 400 `{error: "invalid payload",
      issues: [...]}`
- [ ] Upsert behaviour: if `match.id` exists, fields are updated;
      otherwise a new row is inserted
- [ ] CSRF middleware does not block this route
- [ ] Handler is **not** exposed under any HTTP method other than POST
      (GET/HEAD/PUT/DELETE → 405)
- [ ] No `.unwrap()` equivalent in TS (no `!`-assertions on env var
      reads) — missing API key in env → server-startup-time failure or
      clear 500 with a logged message

### macht-api
- [ ] Importer reads `MATCH_IMPORT_API_KEY` from env and sends it as
      `x-api-key` on every match upsert call
- [ ] `Origin: RUST_APPLICATION` is removed from the request
- [ ] `cargo clippy -- -D warnings` and `cargo test` pass

### Quality gates
- [ ] `pnpm exec tsc --noEmit` (frontend) clean
- [ ] `pnpm exec vitest run` (frontend) green if tests are added
- [ ] No new `.unwrap()` in Rust; no `any` in TS

## Verification (manual)

1. `cd frontend && pnpm dev` (with `MATCH_IMPORT_API_KEY=devkey` in `.env`)
2. `curl -X POST http://localhost:3000/api/match/import \
      -H 'content-type: application/json' \
      -H 'x-api-key: devkey' \
      -d '{"id":99,"homeTeam":{"name":"X","tla":"XXX"},"awayTeam":{"name":"Y","tla":"YYY"},"status":"SCHEDULED","utcDate":1700000000}'`
   → 200 with `{ok: true, id: 99}`. Row 99 visible in `match` table.
3. Re-run with `id=99` and a new status → row updates (no duplicate)
4. Drop the header → 401
5. Wrong header value → 401 (no information disclosure about why)
6. Wrong method (`curl -X GET ...`) → 405
7. With macht-api configured to use the same key, run one cron tick →
   matches arrive in the frontend DB

## Notes (multi-repo only)

Implementation order:

1. `frontend/app/api/match/import/route.ts` — new handler + Zod schema
2. `frontend/middleware.ts` — bypass CSRF for `/api/match/import`
3. `frontend/.env.example` — document `MATCH_IMPORT_API_KEY`
4. `macht-api/src/api/match_client.rs` — send `x-api-key`, stop setting
   `Origin: RUST_APPLICATION`
5. `macht-api/.env.example` — document `MATCH_IMPORT_API_KEY`
6. Coordinated rollout: ship both commits before deploying either, or
   accept a brief window where the importer fails (deploy frontend first
   since the old endpoint does not exist in the new app)

Depends on **FE-001** (env wiring, middleware skeleton) and the schema
work it includes. Independent of FE-002…FE-006 — can run in parallel
once FE-001 is merged.
