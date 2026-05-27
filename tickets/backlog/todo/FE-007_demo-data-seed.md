# [FE-007] Demo-data seed script for local dev + tests

## Repo
frontend

## Type
chore

## Risk
low

## Priority
high

## Status
todo

## Owner
implementer

## Background
The Next.js frontend reads from a shared SQLite file (`shared/db/database.db`).
Without seeded users, matches, and tips, the dashboard renders empty, the
ranking is blank, no point colors (4/2/1/0) are visible, and FE-005/FE-006
manual verifications cannot be executed.

This ticket adds an **idempotent** seed script that wipes the user/match/tip/
session tables and re-inserts the canonical demo dataset defined in
`FRONTEND_FUNKTIONS_SPEC.md` §20. The script reads the DB path from
`process.env.DATABASE_URL`, so the same script seeds dev (`shared/db/database.db`)
and test (`shared/db/test.db`) depending on the active dotenv file.

## Scope

**In scope:**
- `scripts/demo_data.ts` — idempotent seed: `delete from session/tip/user/match`
  then bulk insert
- 8 users across the 3 real departments (Mainz / Mannheim / Langenfeld),
  per spec §20.4
- 12 matches: 4 FINISHED (past), 2 IN_PLAY (around `now`), 6 SCHEDULED (future)
- Tip matrix designed so every point color appears: at least one row of
  +4 (exact), +2 (goal diff), +1 (winner), and 0 (wrong)
- Argon2id-hashed password `test123` for every user (computed at seed-time,
  not hardcoded)
- `package.json` scripts:
  - `db:seed` (uses `.env`)
  - `db:seed:test` (uses `.env.test`)
  - `db:reset` (rm DB file + migrate + seed)
  - `db:fresh` alias

**Out of scope (explicit):**
- Schema changes (FE-001 handles schema 1:1 with Astro)
- Match-import API endpoint (FE-008)
- CI integration of the seed (separate DevOps ticket)

## References

- `docs/FRONTEND_FUNKTIONS_SPEC.md` §20 (full seed spec including
  user list, match buckets, NPM scripts, env conventions)
- `em2024-frontend/scripts/demo_data.ts` — original Astro seed (for
  structural reference only — the user roster is different)
- `betting-api/src/db/fixtures.rs` — Rust test fixtures (must not collide
  with this seed; the Rust file only runs in `cargo test`)

## Acceptance Criteria

### Seed content
- [ ] 8 users with these usernames + departments (per spec §20.4):
      AdaLovelace (Mainz), AlanTuring (Mainz),
      MarieCurie (Mannheim), NikolaTesla (Mannheim), RosaParks (Mannheim),
      TestUser (Langenfeld, email `me@dev.local`), AlbertEinstein (Langenfeld),
      IsaacNewton (Langenfeld)
- [ ] Every user has Argon2id-hashed password for plaintext `test123`,
      computed at seed time (no hash committed)
- [ ] Every user has `winner` and `secretWinner` set, with `winner !== secretWinner`
- [ ] 12 matches inserted with relative dates anchored to `Date.now()`:
      4 with `status='FINISHED'` and past `utcDate`,
      2 with `status='IN_PLAY'` and `utcDate ≈ now`,
      6 with `status='SCHEDULED'` and future `utcDate`
- [ ] Match `homeTeam` / `awayTeam` are JSON objects `{name, tla}` with
      TLA codes that have a matching flag SVG in `public/svg/`
- [ ] Tips inserted for the FINISHED + IN_PLAY matches such that the
      ranking exposes **all four** point colors: at least one row of +4,
      one of +2, one of +1, one of 0
- [ ] No two users tie in total points (ranking is unambiguous for tests)

### Idempotence + isolation
- [ ] Running `pnpm db:seed` twice produces the same DB state (no PK
      collisions, no duplicates, no orphan tips)
- [ ] `pnpm db:seed:test` writes to `shared/db/test.db`, not `database.db`
- [ ] Seed never touches the `match` table when the `MATCH_TABLE_FROZEN`
      env flag is set (allows running the seed against a DB that the Rust
      importer is already populating)

### Script + DX
- [ ] `pnpm db:reset` removes the DB file, re-runs Drizzle migrations,
      then runs the seed — finishes in < 5 s on a fresh checkout
- [ ] Script exits with non-zero on any error (no swallowed failures)
- [ ] No secrets in the script source (passwords are constants for dev
      only — fine to hardcode `test123` for demo data)

## Verification (manual)

1. `cd frontend && pnpm db:reset` → script completes, prints the user
   count (8) and match count (12)
2. `pnpm dev` → open `/login`, sign in as `me@dev.local` / `test123` →
   land on `/` with a populated dashboard (live block + upcoming list +
   ranking sidebar)
3. Inspect `/table` → 8 users visible, every department tab non-empty,
   point colors mixed (green/yellow/neutral/red)
4. Run `pnpm db:seed` again → no errors, same row counts
5. Open `shared/db/database.db` in a SQLite viewer → 8 user rows,
   12 match rows, ≥10 tip rows; passwords are Argon2id hashes (start
   with `$argon2id$…`), not plaintext

## Notes

Depends on **FE-001** (Drizzle schema + `DATABASE_URL` env wiring).
Unblocks **FE-003**, **FE-005**, **FE-006** manual verification and
**FE-010** (tests run against the seed).
