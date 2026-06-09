# MA-008 macht-api: raise importer test coverage + concurrency safety

## Repo
macht-api

## Type
chore

## Risk
low

## Priority
medium

## Background
`macht-api` has low code coverage on its most failure-prone surface: the
deserialization of the external football-data.org payload into the `Match` /
`Team` / `Score` structs, and the JSON it serializes back into the shared
`match` table that `betting-api` and the frontend read. Existing tests cover the
helpers (`sanitize_field`, `team_determined`, `normalize_team`) and the
DB-backed `save_matches_to_sqlite` path, but not the API contract itself.

Separately, the operator's main concern is connection robustness: three
processes share one SQLite file (frontend read+write, betting-api read, macht-api
read+write) and a write must not fail under contention. WAL + `busy_timeout=5000`
are already configured on all three; this ticket adds `PRAGMA synchronous =
NORMAL` on the macht-api writer (safe under WAL, shortens the write-lock hold
time) and a regression test that proves concurrent writers + a reader complete
without lock errors.

## Scope
- **In scope**:
  - Extract the connection PRAGMA setup in `match_client.rs` into a small
    `configure_connection(&Connection)` helper used by `get_connection`, so it
    is unit-testable; add `PRAGMA synchronous = NORMAL` there.
  - Add pure unit tests (no DB, no network):
    - Upstream deserialization: full match payload; response without a
      `matches` key → `matches: None` (the abort-without-changes path);
      knockout placeholder with null teams; `crest` → `flag` serde rename;
      missing `regularTime`.
    - Serialization lockstep contract: `Team` serializes with keys `name`,
      `tla`, `crest` (not the internal `flag`) — what the frontend/betting-api
      read from the `homeTeam`/`awayTeam` JSON columns.
    - `sanitize_field` truncates on a char boundary for multibyte input.
  - Add a concurrency regression test using its own temp DB file: N writer
    threads + a reader thread against one WAL DB with `configure_connection`
    all succeed; final row count is exact.
- **Out of scope (explicit)**:
  - No change to import logic, cadence, or the `save_matches_to_sqlite` flow.
  - No change to WAL / `busy_timeout` values.
  - `synchronous = NORMAL` on the frontend / betting-api connections (separate
    repos; follow-up if desired — betting-api is read-only so it is moot there).

## References
- `macht-api/src/api/match_client.rs` (`get_connection`, structs, helpers)
- `macht-api/.github/workflows/macht-api-ci.yml` (serial tests, tarpaulin)
- `frontend/db/schema.ts` (`homeTeam`/`awayTeam` JSON shape `{name, tla, crest?}`)
- `betting-api/src/db/mod.rs` (reads the same JSON)

## Acceptance Criteria
- [ ] `configure_connection` exists, is used by `get_connection`, and sets
      `busy_timeout`, `journal_mode = WAL`, and `synchronous = NORMAL`.
- [ ] New deserialization tests cover: full payload, missing `matches` key,
      null-team placeholder, `crest`→`flag` rename, absent `regularTime`.
- [ ] Serialization test asserts the `Team` JSON has `name`/`tla`/`crest` and
      no `flag` key.
- [ ] `sanitize_field` multibyte test asserts char-count cap and valid UTF-8.
- [ ] Concurrency test: ≥3 concurrent writers + 1 reader on one WAL temp DB
      finish with no `SQLITE_BUSY`/panic; final count equals writes.
- [ ] Quality Gate (macht-api): `cargo fmt --all -- --check`,
      `cargo clippy --all-targets -- -D warnings`, `cargo test --locked` all green.
- [ ] No `.unwrap()` added to production paths (tests may use it).

## Verification (manual)
1. `cd macht-api && cargo test` → all green, including the new tests.
2. `cargo clippy --all-targets -- -D warnings` → clean.
3. Coverage (tarpaulin) on `match_client.rs` increases vs. the previous run.
