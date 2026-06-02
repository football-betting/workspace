# MA-006 — Add macht-api CI — Result

> The merged PR and squash commit carry the prefix `MA-005` (numbering slip).
> Canonical ticket: **MA-006**.

## What was done
Added a CI workflow to macht-api (the repo's default branch is `master`):
- Toolchain via `dtolnay/rust-toolchain@stable` (rustfmt + clippy),
  `Swatinem/rust-cache@v2`.
- `cargo fmt --all -- --check`, `cargo clippy --all-targets -- -D warnings`,
  `cargo test --locked`, tarpaulin coverage → Codecov.
- The tests are integration tests that need a `match`-table DB via `DB_PATH`.
  CI seeds a throwaway SQLite DB (`$GITHUB_WORKSPACE/ci-test.db`) with the
  `match` schema (mirrors `frontend/db/migrations/0000_*.sql`) in WAL mode, and
  runs with `RUST_TEST_THREADS=1` — tests share one DB file and reuse match ids,
  so they must run serially, and WAL avoids the `journal_mode` lock contention a
  fresh DB hits. The shared dev DB is never touched.
- Fixed a 23-line rustfmt drift in `src/api/match_client.rs` (no logic change)
  so the format check passes.
- README status + Codecov badges added.

## Files changed (macht-api)
- `.github/workflows/macht-api-ci.yml` — new
- `src/api/match_client.rs` — rustfmt only
- `Readme.md` — badges

Delivered via PR football-betting/macht-api#7 (squash-merged into `master`).

## Test results (CI, green)
- `cargo fmt --check`: clean (after the drift fix)
- `cargo clippy -- -D warnings`: clean
- `cargo test`: 6 passed against the seeded throwaway DB
  (`DB_PATH=/home/runner/work/macht-api/macht-api/ci-test.db`)
- Codecov upload: success (org `CODECOV_TOKEN`, token length 36)
- Run time ~2m37s
