# MA-003 Update macht-api for WC 2026 and migrate DB path

## Repo
macht-api

## Type
chore

## Risk
low

## Priority
high

## Status
review

## Owner
implementer

## Background
The external football-data.org API has been updated to serve FIFA World Cup 2026
data at `v4/competitions/WC/matches`. The API response schema is compatible with
the existing Rust structs (verified against live response with 104 matches).
Two things need updating:

1. `.env.dist` must reflect the correct `API_URI` and new `DB_PATH`
   (`../shared/db/database.db` per workspace architecture).
2. The `shared/db/` directory must be created and the database file moved there
   so all three services share the neutral path.
3. A full import run (`cargo run -- --full`) must succeed and populate the DB
   with WC 2026 matches.

## Scope
- **In scope**:
  - Update `rust-api/.env.dist` with correct `API_URI` and `DB_PATH`
  - Update `rust-api/.env` with new `DB_PATH`
  - Create `shared/db/` directory
  - Copy existing `database.db` to `shared/db/`
  - Run full import and verify matches are written
- **Out of scope (explicit)**:
  - Rust code changes (schema already compatible)
  - betting-api `.env` update (separate ticket)
  - Frontend changes
  - Error handling / `.unwrap()` cleanup (see RUST_VERBESSERUNGEN.md)

## References
- `rust-api/src/api/match_client.rs` — API structs and import logic
- `rust-api/.env.dist` — env template
- `docs/TECH_ARCHITEKTUR.md` section 21 — DB path migration plan

## Acceptance Criteria
- [ ] `shared/db/database.db` exists and is writable
- [ ] `rust-api/.env.dist` has `API_URI=https://api.football-data.org/v4/competitions/WC/matches`
- [ ] `rust-api/.env.dist` has `DB_PATH=../shared/db/database.db`
- [ ] `cargo run -- --full` in `rust-api/` completes without panic
- [ ] `SELECT count(*) FROM match` returns >= 104 rows after import
- [ ] Quality Gate passes: `cargo fmt --check && cargo clippy --all-targets -- -D warnings && cargo test`

## Verification (manual)
1. `cd rust-api && cargo run -- --full` -> exits 0, no panic
2. `sqlite3 ../shared/db/database.db "SELECT count(*) FROM match;"` -> `104`
3. `sqlite3 ../shared/db/database.db "SELECT id, status, homeTeam FROM match LIMIT 3;"` -> rows with WC 2026 data
