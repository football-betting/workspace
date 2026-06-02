# MA-007 — Update macht-api README — Result

## What was done
Rewrote `macht-api/Readme.md`:
- Retitled from "Rust Api" to macht-api, described as the scheduled match-data
  importer (Rust + Tokio) that fetches from an external football API and writes
  the shared SQLite DB.
- Added an Architecture section (shared DB, sole writer of the `match` table,
  schema lockstep with the frontend).
- Documented configuration (`X_AUTH_TOKEN`, `API_URI`, `DB_PATH`), incremental
  vs `--full` import, and safe integration-test instructions
  (`RUST_TEST_THREADS=1` + throwaway `DB_PATH`, never the shared DB).
- Removed the stale `key.json` step (no longer referenced anywhere in the repo).

## Files changed
- `Readme.md`

Delivered via PR football-betting/macht-api#8 (squash-merged into `master`).

## Test results
CI green (fmt · clippy · test · coverage, ~2m36s) on the PR.
