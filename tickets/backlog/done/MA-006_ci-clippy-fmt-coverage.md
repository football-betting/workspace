# MA-006 Add macht-api CI (clippy, fmt, test, coverage)

> Note: the merged PR (football-betting/macht-api#7) and its squash commit use
> the prefix `MA-005` due to a numbering slip; the canonical ticket number is
> **MA-006** (MA-005 was already taken by the skip-undetermined-team-matches
> ticket).

## Repo
macht-api

## Type
chore

## Risk
low

## Priority
medium

## Background
macht-api has no CI. We want the same gate as the other services: fmt-check +
clippy + tests + coverage, with a status and Codecov badge. macht-api's tests
are integration tests: they read `DB_PATH` and operate on a SQLite DB that must
already contain the `match` table (frontend schema). Locally they run against
the shared dev DB, which is unsafe in CI and pollutes shared state — so CI must
seed a throwaway DB.

## Scope
- **In scope**:
  - `.github/workflows/macht-api-ci.yml` — rust-toolchain (clippy+rustfmt),
    rust-cache, fmt-check, clippy `-D warnings`, seed a temp `match`-table DB
    (WAL), `cargo test` with `RUST_TEST_THREADS=1`, tarpaulin coverage → Codecov.
    Triggers on `master` (repo default branch).
  - `src/api/match_client.rs` — `cargo fmt` to clear a 23-line rustfmt drift so
    `fmt --check` passes (no logic change).
  - `README.md` — status + Codecov badges.
- **Out of scope (explicit)**:
  - Restructuring the tests to be self-isolating (each its own temp DB). CI
    seeding + single-threaded run is sufficient.

## Notes
- Tests share one DB file and reuse ids (e.g. 11111) across cases, so they must
  run single-threaded (`RUST_TEST_THREADS=1`); the seed DB is put in WAL mode to
  avoid the `PRAGMA journal_mode=WAL` lock contention seen on a fresh DB.
- `match` DDL mirrors `frontend/db/migrations/0000_*.sql`.

## Acceptance Criteria
- [ ] Push/PR to `master` triggers CI; fmt-check, clippy `-D warnings`,
      `cargo test` all green against the seeded throwaway DB.
- [ ] Coverage uploaded to Codecov (org `CODECOV_TOKEN`).
- [ ] No test ever touches `../shared/db`.

## Verification (manual)
1. Open PR → CI green.
2. CI log shows DB_PATH pointing at a workspace temp file, not shared/db.
